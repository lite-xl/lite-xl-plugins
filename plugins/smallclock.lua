-- mod-version:3 --lite-xl 2.1
local core = require "core"
local style = require "core.style"
local StatusView = require "core.statusview"

local time = ""

local last_time = os.time()
local function update_time()
  if os.time() > last_time then
    local t = os.date("*t")
    time = string.format("%02d:%02d", t.hour, t.min)
    last_time = os.time()
  end
end

core.status_view:add_item(
  nil,
  "status:small-clock",
  StatusView.Item.RIGHT,
  function()
    update_time()
    return {style.accent, time}
  end,
  nil,
  -1
).separator = core.status_view.separator2
