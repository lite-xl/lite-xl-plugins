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
    caret_color = table.pack(table.unpack(style.caret)),
    surrounding_chars = false,
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
      },
      {
        label = "Surrounding Characters",
        description = "When using block caret, whether you want to show the characters around for a better character switch.",
        path = "surrounding_chars",
        type ="toggle",
        default = false,
      },
    }

    ---@cast settings plugins.settings
    settings.ui:enable_plugin("custom_caret")
  end
end)

local caret_idx = 1

local docview_update = DocView.update
function DocView:update()
  docview_update(self)
  caret_idx = 1
end

function DocView:draw_caret(x, y)
  local caret_width = style.caret_width
  local caret_height = self:get_line_height()
  local current_caret_shape = conf.shape
  local caret_color = conf.custom_color and conf.caret_color or style.caret

  local font = self:get_font()
  local line, col = self.doc:get_selection_idx(caret_idx)
  local charw = math.ceil(font:get_width(self.doc:get_char(line, col)))

  if (current_caret_shape == "block") then
    caret_width = charw
  elseif (current_caret_shape == "underline") then
    caret_width = charw
    caret_height = style.caret_width*2
    y = y+self:get_line_height()
  else
    caret_width = style.caret_width
    caret_height = self:get_line_height()
  end

  renderer.draw_rect(x, y, caret_width, caret_height, caret_color)
  if current_caret_shape == "block" then
    core.push_clip_rect(x, y, caret_width, caret_height)

    local function draw_char(l, c)
      l = common.clamp(l, 1, #self.doc.lines   )
      c = common.clamp(c, 1, #self.doc.lines[l])
      local cx,cy = self:get_line_screen_position(l, c)
      renderer.draw_text(
        font, self.doc:get_char(l, c),
        cx, cy+self:get_line_text_y_offset(),
        style.background
      )
    end

    if conf.surrounding_chars then
      for yo=-1, 1 do
        for xo=-1, 1 do
          draw_char(line+xo, col+yo)
        end
      end
    else
      draw_char(line, col)
    end

    core.pop_clip_rect()
  end

  caret_idx = caret_idx + 1
end
