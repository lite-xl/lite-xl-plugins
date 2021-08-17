-- mod-version:2 -- lite-xl 2.0
local core = require "core"

-- Load a specific theme when the filename of an active document does match
-- a pattern.

-- usage:
-- require("plugins.themeselect").add_pattern("%.md$", "summer")

local theme_select = { }

local saved_colors_module = "core.style"

local themes_patterns = {
}

local reload_module = core.reload_module
local set_visited = core.set_visited

function core.reload_module(name)
  if name:match("^colors%.") then
    saved_colors_module = name
  end
  reload_module(name)
end

function core.set_visited(filename)
  set_visited(filename)
  for _, select in ipairs(themes_patterns) do
    if filename:match(select.pattern) then
      reload_module("colors." .. select.theme)
      return
    end
  end
  if saved_colors_module then
    reload_module(saved_colors_module)
  end
end

function theme_select.add_pattern(pattern, theme)
  table.insert(themes_patterns, {pattern = pattern, theme = theme})
end

function theme_select.clear_patterns()
  themes_patterns = {}
end

return theme_select
