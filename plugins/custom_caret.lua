-- mod-version:3

--[[
  Plugin to customize the caret in the editor
  Thanks to @Guldoman for the initial example

  Features
    1. Change the Color and Opacity of the caret
    2. Change the Shape of the caret, available shapes are Line, Block, Underline
    3. Change the dimensions of the caret

  Customizing the Caret (this can be changed from the .config/lite-xl/init.lua file)
    1. config.plugins.custom_caret.shape - Change the shape of the caret [string]
    2. config.plugins.custom_caret.color - Change the color of the caret in rgba [table]
    3. config.plugins.custom_caret.width - Change the width of the caret [number]
    4. config.plugins.custom_caret.height - Change the height of the caret [number]
]]

local core = require "core"
local style = require "core.style"
local config = require "core.config"
local DocView = require "core.docview"

config.plugins.custom_caret = {}

function DocView:draw_caret(x, y)
  local lh = self:get_line_height()
  local caret_top_width = math.ceil(self:get_font():get_width("a"))

  if (config.plugins.custom_caret.shape == "Line") then
    config.plugins.custom_caret.width = style.caret_width
    config.plugins.custom_caret.height = lh
  elseif (config.plugins.custom_caret.shape == "Block") then
    config.plugins.custom_caret.width = caret_top_width
    config.plugins.custom_caret.height = lh
  elseif (config.plugins.custom_caret.shape == "Underline") then
    config.plugins.custom_caret.width = caret_top_width
    config.plugins.custom_caret.height = style.caret_width*1.5
    y = y+lh
  else
    config.plugins.custom_caret.width = style.caret_width
    config.plugins.custom_caret.height = lh
  end

  renderer.draw_rect(x, y, config.plugins.custom_caret.width, config.plugins.custom_caret.height, config.plugins.custom_caret.color)
end
