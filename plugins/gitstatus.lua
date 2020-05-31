local core = require "core"
local config = require "core.config"
local style = require "core.style"
local StatusView = require "core.statusview"


local git = {
  branch = nil,
  inserts = 0,
  deletes = 0,
}


local function exec(cmd, wait)
  local tempfile = core.temp_filename()
  system.exec(string.format("%s > %q", cmd, tempfile))
  coroutine.yield(wait)
  local fp = io.open(tempfile)
  local res = fp:read("*a")
  fp:close()
  os.remove(tempfile)
  return res
end


core.add_thread(function()
  while true do
    if system.get_file_info(".git") then
      -- get branch name
      git.branch = exec("git rev-parse --abbrev-ref HEAD", 1):match("[^\n]*")

      -- get diff
      local line = exec("git diff --stat", 1):match("[^\n]*%s*$")
      git.inserts = tonumber(line:match("(%d+) ins")) or 0
      git.deletes = tonumber(line:match("(%d+) del")) or 0

    else
      git.branch = nil
    end

    coroutine.yield(config.project_scan_rate)
  end
end)


local get_items = StatusView.get_items

function StatusView:get_items()
  if not git.branch then
    return get_items(self)
  end
  local left, right = get_items(self)

  local t = {
    style.dim, self.separator,
    (git.inserts ~= 0 or git.deletes ~= 0) and style.accent or style.text,
    git.branch,
    style.dim, "  ",
    git.inserts ~= 0 and style.accent or style.text, "+", git.inserts,
    style.dim, " / ",
    git.deletes ~= 0 and style.accent or style.text, "-", git.deletes,
  }
  for _, item in ipairs(t) do
    table.insert(right, item)
  end

  return left, right
end

