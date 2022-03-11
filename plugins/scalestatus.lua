-- mod-version:3 --lite-xl 2.1
--[[
    scalestatus.lua
    displays current scale (zoom) in status view
    version: 20200628_155804
    originally by SwissalpS
--]]
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local scale = require "plugins.scale"
local StatusView = require "core.statusview"

config.plugins.scalestatus = common.merge(
  { format = '%.0f%%' },
  config.plugins.scalestatus
)

core.status_view:add_item(
  nil,
  "status:scale",
  StatusView.Item.RIGHT,
  function()
    return {string.format(
      config.plugins.scalestatus.format,
      scale.get() * 100
    )}
  end,
  nil,
  1,
  "scale"
).separator = core.status_view.separator2

return true

