-- mod-version:3

--[[
  Author: techie-guy

  Plugin to customize the caret in the editor
  Thanks to @Guldoman for the initial example on Discord

  Features
    Change the Color and Opacity of the caret
    Change the Shape of the caret, available shapes are Line, Block, Underline

  Customizing the Caret: (this can be changed from the .config/lite-xl/init.lua
  file or from the settings menu plugin)
    config.plugins.custom_caret.shape - Change the shape of the caret [string]
    style.caret - Change the rgba color of the caret [table]

  Example Config(in the .config/lite-xl/init.lua)
    style.caret = {0, 255, 255, 150}
    config.plugins.custom_caret.shape = "block"
]]

local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"

config.plugins.custom_caret = common.merge({
    shape = "line",
    custom_color = true,
    caret_color = table.pack(table.unpack(style.caret))
}, config.plugins.custom_caret)

-- Reference to plugin config
local conf = config.plugins.custom_caret

-- Get real default caret color after everything is loaded up
core.add_thread(function()
  if
    conf.caret_color[1] == 147 and conf.caret_color[2] == 221
    and
    conf.caret_color[3] == 250 and conf.caret_color[4] == 255
    and
    (
      style.caret[1] ~= conf.caret_color[1] or style.caret[2] ~= conf.caret_color[2]
      or
      style.caret[3] ~= conf.caret_color[3] or style.caret[4] ~= conf.caret_color[4]
    )
  then
    conf.caret_color = table.pack(table.unpack(style.caret))
  end

  local settings_loaded, settings = pcall(require, "plugins.settings")
  if settings_loaded then
    conf.config_spec = {
      name = "Custom Caret",
      {
        label = "Shape",
        description = "The Shape of the cursor.",
        path = "shape",
        type = "selection",
        default = "line",
        values = {
          {"Line", "line"},
          {"Block", "block"},
          {"Underline", "underline"}
        }
      },
      {
        label = "Custom Color",
        description = "Use a custom color for the caret as specified below.",
        path = "custom_color",
        type = "toggle",
        default = true
      },
      {
        label = "Caret Color",
        description = "Custom color of the caret.",
        path = "caret_color",
        type = "color",
        default = table.pack(table.unpack(style.caret)),
      }
    }

    ---@cast settings plugins.settings
    settings.ui:enable_plugin("custom_caret")
  end
end)

function DocView:draw_caret(x, y)
  local caret_width = style.caret_width
  local caret_height = self:get_line_height()
  local current_caret_shape = conf.shape
  local caret_color = conf.custom_color and conf.caret_color or style.caret

  if (current_caret_shape == "block") then
    caret_width = math.ceil(self:get_font():get_width("a"))
  elseif (current_caret_shape == "underline") then
    caret_width = math.ceil(self:get_font():get_width("a"))
    caret_height = style.caret_width*2
    y = y+self:get_line_height()
  else
    caret_width = style.caret_width
    caret_height = self:get_line_height()
  end

  renderer.draw_rect(x, y, caret_width, caret_height, caret_color)
end
