-- mod-version:2 -- lite-xl 2.00
local core = require "core"
local style = require "core.style"
local status_view = require "core.statusview"

local time = ""

core.add_thread(function()
  while true do
    local t = os.date("*t")
    time = string.format("%02d:%02d", t.hour, t.min)
    coroutine.yield(1)
  end
end)

local get_items = status_view.get_items

function status_view:get_items()
  local left, right = get_items(self)
  local t = {style.dim, self.separator2, style.accent, time}

  for _, item in ipairs(t) do
    table.insert(right, item)
  end

  return left, right
end
