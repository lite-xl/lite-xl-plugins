-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local style = require "core.style"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"
local StatusView = require "core.statusview"

---@type thread
local thread = nil
if pcall(require, "thread") then
  thread = require "thread"
end

local project_files = {}
local refresh_files = false
local matching_files = 0
local project_total_files = 0
local loading_text = ""
local project_directory = ""
local coroutine_running = false


local function basedir_files()
  local files = system.list_dir(project_directory)
  local files_return = {}

  if files then
    for _, file in ipairs(files) do
      local info = system.get_file_info(
        project_directory .. PATHSEP .. file
      )

      if info and not common.match_pattern(file, config.ignore_files) then
        if info.type ~= "dir" then
          table.insert(files_return, file)
        end
      end
    end
  end

  if project_total_files == 0 then
    project_total_files = #files_return
  end

  return files_return
end


local function update_suggestions()
  if
    core.active_view == core.command_view
    and
    core.command_view.label == "Open File From Project: "
  then
    core.command_view:update_suggestions()
  end
end


local function update_loading_text(init)
  if init then
    loading_text = "[-]"
    return
  elseif type(init) == "boolean" then
    loading_text = "Matches:"
    return
  end

  if loading_text == "[-]" then
    loading_text = "[\\]"
  elseif loading_text == "[\\]" then
    loading_text = "[|]"
  elseif loading_text == "[|]" then
    loading_text = "[/]"
  elseif loading_text == "[/]" then
    loading_text = "[-]"
  end
end


local function index_files_thread(pathsep, ignore_files)
  local commons = require "core.common"

  local thread = require("thread")

  ---@type thread.Channel
  local input = thread.get_channel("findfileimproved_write")
  ---@type thread.Channel
  local output = thread.get_channel("findfileimproved_read")

  local root = input:wait()
  input:pop()

  output:push("indexing")

  local count = 0
  local directories = {""}
  local files_found = {}

  while #directories > 0 do
    for didx, directory in ipairs(directories) do
      local dir_path = ""

      if directory ~= "" then
        dir_path = root .. pathsep .. directory
        directory = directory .. pathsep
      else
        dir_path = root
      end

      local files = system.list_dir(dir_path)

      if files then
        for _, file in ipairs(files) do
          local info = system.get_file_info(
            dir_path .. pathsep .. file
          )

          if
            info and not commons.match_pattern(
              file, ignore_files
            )
          then
            if info.type == "dir" then
              table.insert(directories, directory .. file)
            else
              table.insert(files_found, directory .. file)
            end
          end
        end
      end
      table.remove(directories, didx)
      break
    end

    count = count + 1
    if count % 500 == 0 then
      output:push(files_found)
      files_found = {}
    end
  end

  if #files_found > 0 then
    output:push(files_found)
  end

  output:push("finished")
end


local function index_files_coroutine()
  while true do
    -- Indexing with thread module/plugin
    if thread and refresh_files then
      ---@type thread.Channel
      local input = thread.get_channel("findfileimproved_read")
      ---@type thread.Channel
      local output = thread.get_channel("findfileimproved_write")

      -- Tell the thread to start indexing the pushed directory
      output:push(project_directory)
      local count = 0

      local indexing_thread = thread.create(
        "findfileimproved", index_files_thread, PATHSEP, config.ignore_files
      )

      while refresh_files do
        local value = input:first()
        count = count + 1

        if value then
          local value_type = type(value)
          if value_type == "string" then
            if value == "indexing" then
              project_files = {}
              update_loading_text(true)
            elseif value == "finished" then
              refresh_files = false
              update_loading_text(false)
              update_suggestions()
            end
          elseif value_type == "table" then
            for _, file in ipairs(value) do
              table.insert(project_files, file)
            end
          end
          input:pop()
        end

        if refresh_files then
          local total_project_files = #project_files
          if total_project_files ~= project_total_files then
            project_total_files = total_project_files
            if project_total_files <= 100000 and count % 10000 == 0 then
              update_suggestions()
            end
          end
        end

        if count % 100 == 0 then
          update_loading_text()
          coroutine.yield()
        end
      end

      coroutine_running = false

      return
    -- Indexing without thread module
    elseif refresh_files then
      refresh_files = false

      project_files = {}
      update_loading_text(true)

      local count = 0
      local suggestions_updated = false
      local root = project_directory
      local directories = {""}

      while #directories > 0 do
        suggestions_updated = false

        for didx, directory in ipairs(directories) do
          local dir_path = ""

          if directory ~= "" then
            dir_path = root .. PATHSEP .. directory
            directory = directory .. PATHSEP
          else
            dir_path = root
          end

          local files = system.list_dir(dir_path)

          if files then
            for _, file in ipairs(files) do
              local info = system.get_file_info(
                dir_path .. PATHSEP .. file
              )

              if
                info and not common.match_pattern(
                  file, config.ignore_files
                )
              then
                if info.type == "dir" then
                  table.insert(directories, directory .. file)
                else
                  table.insert(project_files, directory .. file)
                end
              end
            end
          end
          table.remove(directories, didx)
          break
        end

        project_total_files = #project_files

        count = count + 1
        if count % 100 == 0 then
          update_loading_text()

          if project_total_files <= 100000 and count % 10000 == 0 then
            update_suggestions()
            suggestions_updated = true
          end

          coroutine.yield()
        end
      end

      update_loading_text(false)

      if not suggestions_updated then
        update_suggestions()
      end
    else
      coroutine.yield(2)
    end
  end
end


local function fuzzy_match_extended(files, visited, text)
  local results = common.fuzzy_match_with_recents(files, visited, text)

  if #results > 80000 then
    return results
  end

  local last_char = text:sub(text:len())

  if last_char == "/" or last_char == "\\" then
    local results_copy = {}
    for _, result in ipairs(results) do
      local idx = result:find(text)
      if idx then
        table.insert(results_copy, result)
      end
    end
    results = results_copy
  end

  return results
end


local function open_project_file()
  local project_dir_changed = false
  if project_directory ~= core.project_dir then
    project_directory = core.project_dir
    project_dir_changed = true
  end

  local base_files = basedir_files()
  if #base_files == 0 then
    return
  end

  refresh_files = true
  if thread and not coroutine_running then
    coroutine_running = true
    core.add_thread(index_files_coroutine)
  end

  core.command_view:enter("Open File From Project",
    function(text)
      core.root_view:open_doc(core.open_doc(common.home_expand(text)))
    end,
    function(text)
      local results = {}
      if text == "" or #project_files == 0 then
        results = common.fuzzy_match_with_recents(
          base_files, core.visited_files, text
        )
      else
        results = common.fuzzy_match_with_recents(
          project_files, core.visited_files, text
        )
      end
      matching_files = #results
      return results
    end
  )
end

--
-- inject changes to lite-xl
--

local status_view_get_items = StatusView.get_items

-- display amount of files and matching results
function StatusView:get_items()
  local left, right = status_view_get_items(self)
  if
    core.active_view == core.command_view
    and
    core.command_view.label == "Open File From Project: "
  then
    local t = {
      style.text,
      style.font,
      loading_text .. " " ..
        tostring(matching_files) ..
        "/" ..
        tostring(project_total_files)
    }
    for i, item in ipairs(t) do
      table.insert(left, i, item)
    end
  end
  return left, right
end

-- register the indexing coroutine
if not thread then
  core.add_thread(index_files_coroutine)
end

-- overwrite core:find-file function
command.map["core:find-file"].perform = open_project_file
