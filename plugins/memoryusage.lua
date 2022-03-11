-- mod-version:3 --lite-xl 2.1
-- original implementation by AqilCont
local core = require "core"
local style = require "core.style"
local StatusView = require "core.statusview"

core.status_view:add_item(
  nil,
  "status:memory-usage",
  StatusView.Item.RIGHT,
  function()
    return {
      style.text,
      string.format(
        "%.2f MB",
        (math.floor(collectgarbage("count") / 10.24) / 100)
      )
    }
  end,
  nil,
  1,
  "lua memory usage"
).separator = core.status_view.separator2

