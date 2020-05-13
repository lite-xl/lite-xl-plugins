local View = require "core.view"

function View:move_towards(t, k, dest)
  if type(t) ~= "table" then
    return self:move_towards(self, t, k, dest)
  end
  t[k] = dest
end
