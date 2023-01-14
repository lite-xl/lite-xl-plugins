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
    color_r = style.caret[1],
    color_g = style.caret[2],
    color_b = style.caret[3],
    opacity = style.caret[4]
}, config.plugins.custom_caret)

-- Reference to plugin config
local conf = config.plugins.custom_caret

-- Get real default caret color after everything is loaded up
core.add_thread(function()
  if
    conf.color_r == 147 and conf.color_g == 221
    and
    conf.color_b == 250 and conf.opacity == 255
    and
    (
      style.caret[1] ~= conf.color_r or style.caret[2] ~= conf.color_g
      or
      style.caret[3] ~= conf.color_b or style.caret[4] ~= conf.opacity
    )
  then
    conf.color_r = style.caret[1]
    conf.color_g = style.caret[2]
    conf.color_b = style.caret[3]
    conf.opacity = style.caret[4]
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
        label = "Red Component of Color",
        description = "The color consists of 3 components RGB, "
          .. "This modifies the 'R' component of the caret's color",
        path = "color_r",
        type = "number",
        min = 0,
        max = 255,
        default = style.caret[1],
        step = 1,
      },
      {
        label = "Green Component of Color",
        description = "The color consists of 3 components RGB, "
          .. "This modifies the 'G' component of the caret's color",
        path = "color_g",
        type = "number",
        min = 0,
        max = 255,
        default = style.caret[2],
        step = 1,
      },
      {
        label = "Blue Component of Color",
        description = "The color consists of 3 components RGB, "
          .. "This modifies the 'B' component of the caret's color",
        path = "color_b",
        type = "number",
        min = 0,
        max = 255,
        default = style.caret[3],
        step = 1,
      },
      {
        label = "Opacity of the Cursor",
        description = "The Opacity of the caret",
        path = "opacity",
        type = "number",
        min = 0,
        max = 255,
        default = style.caret[4],
        step = 1,
      },
    }

    ---@cast settings plugins.settings
    settings.ui:enable_plugin("custom_caret")
  end
end)

function DocView:draw_caret(x, y)
  local caret_width = style.caret_width
  local caret_height = self:get_line_height()
  local current_caret_shape = conf.shape
  local caret_color = conf.custom_color and {
    conf.color_r,
    conf.color_g,
    conf.color_b,
    conf.opacity
  } or style.caret

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
