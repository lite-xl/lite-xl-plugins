local core = require "core"
local View = require "core.view"

function View:move_towards(t, k, dest)
  if type(t) ~= "table" then
    return self:move_towards(self, t, k, dest)
  end
  if t[k] ~= dest then
    core.redraw = true
  end
  t[k] = dest
end
