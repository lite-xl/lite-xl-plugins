-- mod-version:3
local core = require "core"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"
local style = require "core.style"
local keymap = require "core.keymap"
local treeview = require "plugins.treeview"
local DocView = require "core.docview"

config.plugins.centerdoc = common.merge({
  enabled = true,
  zen_mode = false
}, config.plugins.centerdoc)

local draw_line_gutter = DocView.draw_line_gutter
local get_gutter_width = DocView.get_gutter_width


function DocView:draw_line_gutter(line, x, y, width)
  local lh
  if not config.plugins.centerdoc.enabled then
    lh = draw_line_gutter(self, line, x, y, width)
  else
    local real_gutter_width = self:get_font():get_width(#self.doc.lines)
    local offset = self:get_gutter_width() - real_gutter_width * 2 - style.padding.x
    lh = draw_line_gutter(self, line, x + offset, y, real_gutter_width)
  end
  return lh
end


function DocView:get_gutter_width()
  if not config.plugins.centerdoc.enabled then
    return get_gutter_width(self)
  else
    local real_gutter_width, gutter_padding = get_gutter_width(self)
    local width = real_gutter_width + self:get_font():get_width("n") * config.line_limit
    return math.max((self.size.x - width) / 2, real_gutter_width), gutter_padding
  end
end


local previous_win_status = system.get_window_mode()
local previous_treeview_status = treeview.visible
local previous_statusbar_status = core.status_view.visible

local function toggle_zen_mode(enabled)
  config.plugins.centerdoc.zen_mode = enabled

  if config.plugins.centerdoc.zen_mode then
    previous_win_status = system.get_window_mode()
    previous_treeview_status = treeview.visible
    previous_statusbar_status = core.status_view.visible

    config.plugins.centerdoc.enabled = true
    system.set_window_mode("fullscreen")
    treeview.visible = false
    command.perform "status-bar:hide"
  else
    config.plugins.centerdoc.enabled = false
    system.set_window_mode(previous_win_status)
    treeview.visible = previous_treeview_status
    core.status_view.visible = previous_statusbar_status
  end
end

local on_startup = true

-- The config specification used by the settings gui
config.plugins.centerdoc.config_spec = {
  name = "Center Document",
  {
    label = "Enable",
    description = "Activates document centering by default.",
    path = "enabled",
    type = "toggle",
    default = true
  },
  {
    label = "Zen Mode",
    description = "Activates zen mode by default.",
    path = "zen_mode",
    type = "toggle",
    default = false,
    on_apply = function(enabled)
      if on_startup then
        core.add_thread(function()
          toggle_zen_mode(enabled)
        end)
        on_startup = false
      else
        toggle_zen_mode(enabled)
      end
    end
  }
}


command.add(nil, {
  ["center-doc:toggle"] = function()
    config.plugins.centerdoc.enabled = not config.plugins.centerdoc.enabled
  end,
  ["center-doc:zen-mode-toggle"] = function()
    toggle_zen_mode(not config.plugins.centerdoc.zen_mode)
  end,
})

keymap.add { ["ctrl+alt+z"] = "center-doc:zen-mode-toggle" }
