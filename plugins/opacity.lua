-- mod-version:2 -- lite-xl 2.0
local common = require "core.common"
local command = require "core.command"
local keymap = require "core.keymap"
local RootView = require "core.rootview"

local opacity_on = true
local use_mousewheel = true
local opacity_steps = 0.05
local default_opacity = 1
local current_opacity = default_opacity

local function set_opacity(opacity)
  if not opacity_on then opacity_on = true end
  current_opacity = common.clamp(opacity, 0.2, 1)
  system.set_window_opacity(current_opacity)
end

local on_mouse_wheel = RootView.on_mouse_wheel

function RootView:on_mouse_wheel(d, ...)
  if keymap.modkeys["shift"] and use_mousewheel then
    if d < 0 then command.perform "opacity:decrease" end
    if d > 0 then command.perform "opacity:increase" end
  else
    return on_mouse_wheel(self, d, ...)
  end
end

local function tog_opacity()
  opacity_on = not opacity_on
  if opacity_on then
    system.set_window_opacity(current_opacity)
  else
    system.set_window_opacity(default_opacity)
  end
end

local function res_opacity()
  set_opacity(default_opacity)
end

local function inc_opacity()
  set_opacity(current_opacity + opacity_steps)
end

local function dec_opacity()
  set_opacity(current_opacity - opacity_steps)
end

command.add(nil, {
  ["opacity:toggle"  ] = function() tog_opacity() end,
  ["opacity:reset"   ] = function() res_opacity() end,
  ["opacity:decrease"] = function() dec_opacity() end,
  ["opacity:increase"] = function() inc_opacity() end,
  ["opacity:toggle mouse wheel use"] = function() use_mousewheel = not use_mousewheel end,
})

keymap.add {
  ["shift+f11"] = "opacity:toggle",
  ["ctrl+f11"]  = "opacity:toggle mouse wheel use",
}
