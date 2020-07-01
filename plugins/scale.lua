--[[
    scale.lua
    provides support for dynamically adjusting the scale of the code font / UI
    version: 20200628_154010
    originally by 6r1d
--]]
local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"
local style = require "core.style"
local RootView = require "core.rootview"

config.scale_mode = "code"
config.scale_use_mousewheel = true

local font_cache = setmetatable({}, { __mode = "k" })

-- the following should be kept in sync with core.style's default font settings
font_cache[style.font]      = { EXEDIR .. "/data/fonts/font.ttf",      14   * SCALE }
font_cache[style.big_font]  = { EXEDIR .. "/data/fonts/font.ttf",      34   * SCALE }
font_cache[style.icon_font] = { EXEDIR .. "/data/fonts/icons.ttf",     14   * SCALE }
font_cache[style.code_font] = { EXEDIR .. "/data/fonts/monospace.ttf", 13.5 * SCALE }


local load_font = renderer.font.load
function renderer.font.load(...)
  local res = load_font(...)
  font_cache[res] = { ... }
  return res
end


local function scale_font(font, s)
  local fc = font_cache[font]
  return renderer.font.load(fc[1], fc[2] * s)
end


local current_scale = SCALE
local default = current_scale


local function get_scale() return current_scale end


local function set_scale(scale)
  scale = common.clamp(scale, 0.2, 6)

  local s = scale / current_scale
  current_scale = scale

  if config.scale_mode == "ui" then
    SCALE = current_scale

    style.padding.x      = style.padding.x      * s
    style.padding.y      = style.padding.y      * s
    style.divider_size   = style.divider_size   * s
    style.scrollbar_size = style.scrollbar_size * s
    style.caret_width    = style.caret_width    * s
    style.tab_width      = style.tab_width      * s

    style.big_font  = scale_font(style.big_font,  s)
    style.icon_font = scale_font(style.icon_font, s)
    style.font      = scale_font(style.font,      s)
  end

  style.code_font = scale_font(style.code_font, s)

  core.redraw = true
end


local on_mouse_wheel = RootView.on_mouse_wheel

function RootView:on_mouse_wheel(d, ...)
  if keymap.modkeys["ctrl"] and config.scale_use_mousewheel then
    if d < 0 then command.perform "scale:decrease" end
    if d > 0 then command.perform "scale:increase" end
  else
    return on_mouse_wheel(self, d, ...)
  end
end


command.add(nil, {
  ["scale:reset"   ] = function() set_scale(default)             end,
  ["scale:decrease"] = function() set_scale(current_scale * 0.9) end,
  ["scale:increase"] = function() set_scale(current_scale * 1.1) end,
})

keymap.add {
  ["ctrl+0"] = "scale:reset",
  ["ctrl+-"] = "scale:decrease",
  ["ctrl+="] = "scale:increase",
}

return { get_scale = get_scale, set_scale = set_scale }

