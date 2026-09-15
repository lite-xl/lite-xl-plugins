-- mod-version:4
local core = require "core"
local common = require "core.common"
local command = require "core.command"
local keymap = require "core.keymap"
local RootView = require "core.rootview"

local opacity_on = true
local use_mousewheel = true
local opacity_steps = 0.05
local default_opacity = 1
local current_opacity = default_opacity

local function set_opacity(window, opacity)
  if not opacity_on then return end
  current_opacity = common.clamp(opacity, 0.2, 1)
  system.set_window_opacity(window.renwindow, current_opacity)
end

local function tog_opacity(window)
  opacity_on = not opacity_on
  if opacity_on then
    core.log("Opacity: on")
    system.set_window_opacity(window.renwindow, current_opacity)
  else
    core.log("Opacity: off")
    system.set_window_opacity(window.renwindow, default_opacity)
  end
end

local function res_opacity(window)
  set_opacity(window, default_opacity)
end

local function inc_opacity(window)
  set_opacity(window, current_opacity + opacity_steps)
end

local function dec_opacity(window)
  set_opacity(window, current_opacity - opacity_steps)
end

command.add(nil, {
  ["opacity:toggle"  ] = function(rv) tog_opacity(rv.window) end,
  ["opacity:reset"   ] = function(rv) res_opacity(rv.window) end,
  ["opacity:decrease"] = function(rv) dec_opacity(rv.window) end,
  ["opacity:increase"] = function(rv) inc_opacity(rv.window) end,
  ["opacity:toggle-mouse-wheel-use"] = function(rv)
    use_mousewheel = not use_mousewheel
    if use_mousewheel then
      core.log("Opacity (shift + mouse wheel): on")
    else
      core.log("Opacity (shift + mouse wheel): off")
    end
  end,
})

keymap.add {
  ["shift+f11"] = "opacity:toggle",
  ["ctrl+shift+wheelup"] = "opacity:increase",
  ["ctrl+shift+wheeldown"] = "opacity:decrease",
  ["ctrl+f11"]  = "opacity:toggle-mouse-wheel-use",
}
