-- mod-version:3

local core = require "core"
local process = require "process"
local command = require "core.command"
local common = require "core.common"
local dirwatch = require "core.dirwatch"

local GitProject = {}

core.git_project = {
  status = nil
}

local function is_in_git(path)
  local proc = process.start(
    { "git", "rev-parse", "--is-inside-work-tree" },
    {
      stdin = process.REDIRECT_DISCARD,
      stdout = process.REDIRECT_PIPE,
      stderr = process.REDIRECT_STDOUT,
      cwd = path,
      timeout = 1.0
    })
  proc:wait(process.WAIT_INFINITE)
  if proc:returncode() == 0 then
    local buf = proc:read_stdout()
    return buf == "true\n"
  end
  return false
end

local function is_ignored(path)
  local proc = process.start(
    { "git", "check-ignore", path },
    {
      stdin = process.REDIRECT_DISCARD,
      stdout = process.REDIRECT_PIPE,
      stderr = process.REDIRECT_STDOUT,
      timeout = 1.0
    })
  proc:wait(process.WAIT_INFINITE)
  local return_code = proc:returncode()
  local buff = proc:read_stdout()
  if return_code == 0 then
    return buff == path .. '\n'
  end
  return buff ~= nil
end


local set_project_dir__orig = core.set_project_dir
function core.set_project_dir(new_dir, chn_proj_fn)
  local ok = set_project_dir__orig(new_dir, chn_proj_fn)
  if ok then
    core.git_project.status = is_in_git(new_dir)
  end
  return ok
end

local function is_project_in_git()
  if core.git_project.status == nil then
    core.git_project.status = is_in_git(core.project_dir)
  end
  return core.git_project.status
end

local add_prj_dir__orig = core.add_project_directory
function core.add_project_directory(path)
  add_prj_dir__orig(path)
end

local function get_project_file_info(root, file)
  local path = root .. PATHSEP .. file
  local info = system.get_file_info(path)
  if info and info.type then
    if info.type == "dir" and file == ".git" then return false end
    info.filename = file
    return not is_ignored(path) and info
  end
  return false
end

local function compare_file(a, b)
  return system.path_compare(a.filename, a.type, b.filename, b.type)
end


local dw_get_directory_files = dirwatch.get_directory_files
function dirwatch.get_directory_files(dir, root, path, entries_count, recurse_pred)
  if is_project_in_git() then
    if is_in_git(dir.name) then
      local t = {}
      local t0 = system.get_time()
      local all = system.list_dir(root .. PATHSEP .. path)
      if not all then return nil end
      local entries = {}
      for _, file in ipairs(all) do
        local info = get_project_file_info(root, (path ~= "" and (path .. PATHSEP) or "") .. file)
        if info then
          table.insert(entries, info)
        end
      end
      table.sort(entries, compare_file)

      local recurse_complete = true
      for _, info in ipairs(entries) do
        table.insert(t, info)
        entries_count = entries_count + 1
        if info.type == "dir" then
          if recurse_pred(dir, info.filename, entries_count, system.get_time() - t0) then
            local t_rec, complete, n = dirwatch.get_directory_files(dir, root, info.filename, entries_count, recurse_pred)
            recurse_complete = recurse_complete and complete
            if n ~= nil then
              entries_count = n
              for _, info_rec in ipairs(t_rec) do
                table.insert(t, info_rec)
              end
            end
          else
            recurse_complete = false
          end
        end
      end

      return t, recurse_complete, entries_count
    else
      return {}, true, entries_count
    end
  else
    dw_get_directory_files(dir, root, path, entries_count, recurse_pred)
  end
end

local function get_git_files()
  local proc = process.start(
    { "git", "ls-files", "--exclude-standard", "--others", "--cached" },
    {
      stdin = process.REDIRECT_DISCARD,
      stdout = process.REDIRECT_PIPE,
      stderr = process.REDIRECT_DISCARD,
      cwd = core.project_dir,
      -- timeout = 1.0
    })
  proc:wait(process.WAIT_INFINITE)
  local return_code = proc:returncode()
  if return_code == 0 then
    local files = {}
    local ok = true
    local file = ''
    local buffer = proc:read_stdout(1)
    ok = buffer and #buffer == 1
    while ok do
      if buffer == '\n' then
        if #file > 0 then
          table.insert(files, file)
          file = ''
        end
      else
        file = file .. buffer
      end
      buffer = proc:read_stdout(1)
      ok = buffer and #buffer == 1
    end
    if #file > 0 then
      table.insert(files, file)
    end
    return files
  else
    return nil
  end
end

command.add(
  nil, {
    ["core:find-project-file"] = function()
      if is_project_in_git() then
        local files = get_git_files()
        if files == nil or #files == 0 then
          return command.perform "core:find-file"
        end
        local options = {
          submit = function(text, item)
            text = item and item.text or text
            core.root_view:open_doc(core.open_doc(common.home_expand(text)))
          end,
          suggest = function(text)
            return common.fuzzy_match_with_recents(files, core.visited_files, text)
          end
        }
        if core.command_view.enter_with_preview then
          options["preview"] = core.command_view.previewer.file_previewer
          core.command_view:enter_with_preview("Open File From Project", options)
        else
          core.command_view:enter("Open File From Project", options)
        end
      else
        return command.perform "core:find-file"
      end
    end
  }
)

-- local prj_subdir_is_shown__orig = core.project_subdir_is_shown
-- function core.project_subdir_is_shown(dir, filename)
--   local ok = prj_subdir_is_shown__orig(dir, filename)
--   if ok and is_project_in_git() then
--     ok = not is_ignored(filename, core.project_dir)
--     print(filename, ok)
--   end
--   return ok
-- end

return GitProject
