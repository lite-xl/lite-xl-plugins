-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local _, TreeView = pcall(require, "plugins.treeview")
local StatusView = require "core.statusview"
local scan_rate = config.project_scan_rate or 5


if TreeView then
  if not (TreeView["set_color_override"] and TreeView["clear_all_color_overrides"]) then
    -- TreeView doesn't have the color override feature we rely on, so skip it.
    TreeView = nil
  end
end


local git = {
  branch = nil,
  inserts = 0,
  deletes = 0,
}


config.gitstatus = {
  recurse_submodules = true
}
style.gitstatus_addition = {common.color "#587c0c"}
style.gitstatus_modification = {common.color "#0c7d9d"}
style.gitstatus_deletion = {common.color "#94151b"}


local function exec(cmd, wait)
  local proc = process.start(cmd)
  proc:wait(wait * 1000)
	local res = proc:read_stdout()
  return res
end


core.add_thread(function()
  while true do
    if system.get_file_info(".git") then
      -- get branch name
      git.branch = exec({"git", "rev-parse", "--abbrev-ref", "HEAD"}, 1):match("[^\n]*")

      if TreeView then
        TreeView:clear_all_color_overrides()
      end

      local inserts = 0
      local deletes = 0

      -- get diff
      local diff = exec({"git", "diff", "--numstat"}, 1)
      if config.gitstatus.recurse_submodules and system.get_file_info(".gitmodules") then
        diff = diff .. exec({"git", "submodule", "foreach", "git diff --numstat --stat"}, 1)
      end

      local root = ""
      for line in string.gmatch(diff, "[^\n]+") do
        local submodule = line:match("^Entering '(.+)'$")
        if submodule then
          root = submodule.."/"
        else
          local ins, dels, path = line:match("(%d+)%s+(%d+)%s+(.+)")
          if path then
            inserts = inserts + (tonumber(ins) or 0)
            deletes = deletes + (tonumber(dels) or 0)
            local abs_path = core.project_dir.."/"..root..path
            if TreeView then
              TreeView:set_color_override(abs_path, style.gitstatus_modification)
            end
          end
        end
      end

      git.inserts = inserts
      git.deletes = deletes

    else
      git.branch = nil
    end

    coroutine.yield(scan_rate)
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

