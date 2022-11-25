-- mod-version:3

--[[
  Author: techie-guy
  
  Plugin to customize the caret in the editor
  Thanks to @Guldoman for the initial example on Discord
  Features:
    1. Change the Color and Opacity of the caret
    2. Change the Shape of the caret, available shapes are Line, Block, Underline
  Customizing the Caret: (this can be changed from the .config/lite-xl/init.lua file or from the settings menu plugin)
    1. style.custom_caret.shape - Change the shape of the caret [string]
    2. style.custom_caret.color - Change the color of the caret [table]
    5. style.custom_caret.opacity - Change the opacity of the caret [number]

  Example Config(in the core/style.lua)
    custom_caret = {
      shape = "line",
      color = {255, 255, 255}
      opacity = 150
    }
]]

local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"

config.plugins.custom_caret = common.merge({
    shape = style.custom_caret.shape,
    color_r = style.custom_caret.color[1],
    color_g = style.custom_caret.color[2],
    color_b = style.custom_caret.color[3],
    opacity = style.custom_caret.opacity,
    -- Config for settings gui
    config_spec = {
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
        label = "Red Component of Color",
        description = "The color consists of 3 components RGB, This modifies the 'R' component of the caret's color",
        path = "color_r",
        type = "number",
        min = 0,
        max = 255,
        default = 255,
        step = 1,
      },
      {
        label = "Green Component of Color",
        description = "The color consists of 3 components RGB, This modifies the 'G' component of the caret's color",
        path = "color_g",
        type = "number",
        min = 0,
        max = 255,
        default = 255,
        step = 1,
      },
      {
        label = "Blue Component of Color",
        description = "The color consists of 3 components RGB, This modifies the 'B' component of the caret's color",
        path = "color_b",
        type = "number",
        min = 0,
        max = 255,
        default = 255,
        step = 1,
      },
      {
        label = "Opacity of the Cursor",
        description = "The Opacity of the caret",
        path = "opacity",
        type = "number",
        min = 0,
        max = 255,
        default = 255,
        step = 1,
      },
    }
}, config.plugins.custom_caret)

function DocView:draw_caret(x, y)
  local caret_width = style.caret_width
  local caret_height = self:get_line_height()
  local current_caret_shape = config.plugins.custom_caret.shape
  local caret_color = {config.plugins.custom_caret.color_r, config.plugins.custom_caret.color_g, config.plugins.custom_caret.color_b, config.plugins.custom_caret.opacity}

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
