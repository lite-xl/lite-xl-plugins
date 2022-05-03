-- mod-version:3 -- lite-xl 2.1
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local StatusView = require "core.statusview"

config.plugins.clock = common.merge({
  format = "%H:%M"
}, config.plugins.clock)

core.status_view:add_item(
  nil,
  "clock:clock",
  StatusView.Item.RIGHT,
  function() return { style.text, os.date(config.plugins.clock.format)  } end
)

