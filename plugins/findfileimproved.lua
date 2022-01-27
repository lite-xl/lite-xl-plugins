-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local style = require "core.style"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"
local StatusView = require "core.statusview"

local project_files = {}
local refresh_files = false
local matching_files = 0
local project_total_files = 0
local loading_text = ""
local project_directory = ""

local function basedir_files()
  local files = system.list_dir(project_directory)
  local files_return = {}

  if files then
    for _, file in ipairs(files) do
      local info = system.get_file_info(
        project_directory .. PATHSEP .. file
      )

      if not common.match_pattern(file, config.ignore_files) then
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

local function index_files_thread()
  while true do
    if refresh_files then
      refresh_files = false

      project_files = {}
      loading_text = "[-]"

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
                not common.match_pattern(
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
          if
            core.active_view == core.command_view
            and
            core.command_view.label == "Open File From Project: "
          then
            core.command_view:update_suggestions()
            suggestions_updated = true
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

          coroutine.yield(0)
        end
      end

      loading_text = "Matches:"

      if
        not suggestions_updated
        and
        core.active_view == core.command_view
        and
        core.command_view.label == "Open File From Project: "
      then
        core.command_view:update_suggestions()
      end
    else
      coroutine.yield(2)
    end
  end
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

  if #project_files <= 0 or project_dir_changed then
    refresh_files = true
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
local core_on_dir_change = core.on_dir_change

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

-- register the indexing thread
core.add_thread(index_files_thread)

-- re-index project files on dir change events
core.on_dir_change = function(watch_id, action, filepath)
  core_on_dir_change(watch_id, action, filepath)
  if action ~= "modify" then
    project_directory = core.project_dir
    refresh_files = true
  end
end

-- overwrite core:find-file function
command.map["core:find-file"].perform = open_project_file
