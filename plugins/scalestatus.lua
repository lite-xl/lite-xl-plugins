-- mod-version:2 -- lite-xl 2.0
--[[
    scalestatus.lua
    displays current scale (zoom) in status view
    version: 20200628_155804
    originally by SwissalpS
--]]
local scale = require "plugins.scale"

local config = require "core.config"
local StatusView = require "core.statusview"

config.plugins.scalestatus = { format = '%.0f%%' }

local get_items = StatusView.get_items
function StatusView:get_items()

  local left, right = get_items(self)

  local t = {
    self.separator,
    string.format(config.plugins.scalestatus.format, scale.get() * 100),
  }

  for _, item in ipairs(t) do
    table.insert(right, item)
  end

  return left, right

end

return true

