-- mod-version:3
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local StatusView = require "core.statusview"
local TreeView = require "plugins.treeview"

config.plugins.gitstatus = common.merge({
  recurse_submodules = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Git Status",
    {
      label = "Recurse Submodules",
      description = "Also retrieve git stats from submodules.",
      path = "recurse_submodules",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.gitstatus)

style.gitstatus_addition = {common.color "#587c0c"}
style.gitstatus_modification = {common.color "#0c7d9d"}
style.gitstatus_deletion = {common.color "#94151b"}

local scan_rate = config.project_scan_rate or 5
local cached_color_for_item = {}


-- Override TreeView's get_item_text to add modification color
local treeview_get_item_text = TreeView.get_item_text
function TreeView:get_item_text(item, active, hovered)
  local text, font, color = treeview_get_item_text(self, item, active, hovered)
  if cached_color_for_item[item.abs_filename] then
    color = cached_color_for_item[item.abs_filename]
  end
  return text, font, color
end


local git = {
  branch = nil,
  inserts = 0,
  deletes = 0,
}

local function exec(cmd)
  local proc = process.start(cmd)
  -- Don't use proc:wait() here - that will freeze the app.
  -- Instead, rely on the fact that this is only called within
  -- a coroutine, and yield for a fraction of a second, allowing
  -- other stuff to happen while we wait for the process to complete.
  while proc:running() do
    coroutine.yield(0.1)
  end
  return proc:read_stdout() or ""
end


core.add_thread(function()
  while true do
    if system.get_file_info(".git") then
      -- get branch name
      git.branch = exec({"git", "rev-parse", "--abbrev-ref", "HEAD"}):match("[^\n]*")

      local inserts = 0
      local deletes = 0

      -- get diff
      local diff = exec({"git", "diff", "--numstat"})
      if
        config.plugins.gitstatus.recurse_submodules
        and
        system.get_file_info(".gitmodules")
      then
        local diff2 = exec({"git", "submodule", "foreach", "git diff --numstat"})
        diff = diff .. diff2
      end

      -- forget the old state
      cached_color_for_item = {}

      local folder = core.project_dir
      for line in string.gmatch(diff, "[^\n]+") do
        local submodule = line:match("^Entering '(.+)'$")
        if submodule then
          folder = core.project_dir .. PATHSEP .. submodule
        else
          local ins, dels, path = line:match("(%d+)%s+(%d+)%s+(.+)")
          if path then
            inserts = inserts + (tonumber(ins) or 0)
            deletes = deletes + (tonumber(dels) or 0)
            local abs_path = folder .. PATHSEP .. path
            -- Color this file, and each parent folder,
            -- so you can see at a glance which folders
            -- have modified files in them.
            while abs_path do
              cached_color_for_item[abs_path] = style.gitstatus_modification
              abs_path = common.dirname(abs_path)
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


core.status_view:add_item({
  name = "status:git",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    if not git.branch then
      return {}
    end
    return {
      (git.inserts ~= 0 or git.deletes ~= 0) and style.accent or style.text,
      git.branch,
      style.dim, "  ",
      git.inserts ~= 0 and style.accent or style.text, "+", git.inserts,
      style.dim, " / ",
      git.deletes ~= 0 and style.accent or style.text, "-", git.deletes,
    }
  end,
  position = -1,
  tooltip = "branch and changes",
  separator = core.status_view.separator2
})
