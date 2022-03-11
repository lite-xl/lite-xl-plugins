-- mod-version:3 --lite-xl 2.1
local core = require "core"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"
local keymap = require "core.keymap"
local treeview = require "plugins.treeview"
local DocView = require "core.docview"

config.plugins.centerdoc = common.merge({
  enable = true
}, config.plugins.centerdoc)

local draw_line_gutter = DocView.draw_line_gutter
local get_gutter_width = DocView.get_gutter_width


function DocView:draw_line_gutter(idx, x, y, width)
  if not config.plugins.centerdoc.enable then
    draw_line_gutter(self, idx, x, y, width)
  else
    local real_gutter_width = get_gutter_width(self)
    local offset = self:get_gutter_width() - real_gutter_width * 2
    draw_line_gutter(self, idx, x + offset, y, real_gutter_width)
  end
end


function DocView:get_gutter_width()
  if not config.plugins.centerdoc.enable then
    return get_gutter_width(self)
  else
    local real_gutter_width = get_gutter_width(self)
    local width = real_gutter_width + self:get_font():get_width("n") * config.line_limit
    return math.max((self.size.x - width) / 2, real_gutter_width)
  end
end

local zen_mode = false
local previous_win_status = system.get_window_mode()
local previous_treeview_status = treeview.visible
local previous_statusbar_status = core.status_view.visible

command.add(nil, {
  ["center-doc:toggle"] = function()
    config.plugins.centerdoc.enable = not config.plugins.centerdoc.enable
  end,
  ["center-doc:zen-mode-toggle"] = function()
    zen_mode = not zen_mode

    if zen_mode then
      previous_win_status = system.get_window_mode()
      previous_treeview_status = treeview.visible
      previous_statusbar_status = core.status_view.visible

      config.plugins.centerdoc.enable = true
      system.set_window_mode("fullscreen")
      treeview.visible = false
      command.perform "status-bar:hide"
    else
      config.plugins.centerdoc.enable = false
      system.set_window_mode(previous_win_status)
      treeview.visible = previous_treeview_status
      core.status_view.visible = previous_statusbar_status
    end
  end,
})

keymap.add { ["ctrl+alt+z"] = "center-doc:zen-mode-toggle" }
