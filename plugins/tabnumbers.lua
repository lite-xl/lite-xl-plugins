-- mod-version:3
local config = require "core.config"
local common = require "core.common"
local style = require "core.style"
local Node = require "core.node"

config.plugins.tabnumbers = common.merge({
  enabled = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Tab Numbers",
    {
      label = "Draw Tab Numbers",
      description = "Show or hide numbers on the interface tabs.",
      path = "enabled",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.tabnumbers)

-- Overwrite draw_tab_title to prepend tab number
local Node_draw_tab_title = Node.draw_tab_title
function Node:draw_tab_title(view, font, is_active, is_hovered, x, y, w, h)
  if config.plugins.tabnumbers.enabled then
    local number = ""
    for i, v in ipairs(self.views) do
      if view == v then
        number = tostring(i)
      end
    end
    local padx = 0
    if number ~= "" then
      padx = style.font:get_width(number) + (style.padding.x / 2)
      w = w - padx
      local color = is_active and style.text or style.dim
      common.draw_text(style.font, color, number, nil, x, y, w, h)
    end
    local tx = x + padx -- Space for number
    Node_draw_tab_title(self, view, font, is_active, is_hovered, tx, y, w, h)
  else
    Node_draw_tab_title(self, view, font, is_active, is_hovered, x, y, w, h)
  end
end
