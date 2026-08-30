-- mod-version:3
local core = require "core"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"

config.plugins.gitopen = common.merge({
  normalize_paths = true,

  config_spec = {
    name = "Git Open",
    {
      label = "Normalize Paths",
      description = "Normalize Git paths by converting '\\' to '/'.",
      path = "normalize_paths",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.gitopen)

local function exec(cmd)
  local proc = process.start(cmd)
  while proc:running() do
    coroutine.yield(0.1)
  end
  if proc:returncode() > 0 then
    core.error("ERROR - command: " .. table.concat(cmd, " "))
  end
  return proc:read_stdout() or ""
end

-- Git for Windows uses / as Unix based systems
local function normalize_path(path)
  if config.plugins.gitopen.normalize_paths then
    return path:gsub('\\', '/')
  end

  return path
end

local function git_find_files_and_open(commit)
  local git_root = exec({"git", "rev-parse", "--show-toplevel"}):match( "^%s*(.-)%s*$" )
  local file_list_str = exec({"git", "show", "--name-only", "--pretty=format:", commit})

  local git_files = {}
  for str in string.gmatch(file_list_str, "([^\n]+)") do
    git_files[normalize_path(git_root .. PATHSEP .. str)] = true
  end

  for dir, item in core.get_project_files() do
    local key = normalize_path(dir .. PATHSEP .. item.filename)
    if git_files[key] then
      core.root_view:open_doc(core.open_doc(item.filename))
    end
  end
end

-- works in any context
command.add(nil, {
  ["gitopen:open-from-commit"] = function(dv)
    core.command_view:enter("Which commit? (default=HEAD)", {
      submit = function(commit)
        if commit == nil or commit == "" then
          commit = "HEAD"
        end
        -- open the files in the background, return immediately
        core.add_thread(
          function ()
            git_find_files_and_open(commit)
          end
        )
      end
    })
  end,
})

