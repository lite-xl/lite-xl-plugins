-- mod-version:2 -- lite-xl 2.0
-- original implementation by AqilCont
local style = require "core.style"
local StatusView = require "core.statusview"

local get_items = StatusView.get_items

function StatusView:get_items()
  local left, right = get_items(self)
  local t = {
    style.text, (math.floor(collectgarbage("count") / 10.24) / 100) .. " MB",
    style.dim, self.separator2,
  }
  for i, item in ipairs(t) do
    table.insert(right, i, item)
  end
  return left, right
end

