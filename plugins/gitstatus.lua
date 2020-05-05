local core = require "core"
local config = require "core.config"
local style = require "core.style"
local StatusView = require "core.statusview"


local git = {
  branch = nil,
  inserts = 0,
  deletes = 0,
}

core.add_thread(function()
  while true do
    if system.get_file_info(".git") then
      -- get branch name
      local fp = io.popen("git rev-parse --abbrev-ref HEAD")
      git.branch = fp:read("*l")
      fp:close()

      -- get diff
      local fp = io.popen("git diff --stat")
      local last_line = ""
      for line in fp:lines() do last_line = line end
      fp:close()
      git.inserts = tonumber(last_line:match("(%d+) ins")) or 0
      git.deletes = tonumber(last_line:match("(%d+) del")) or 0

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

