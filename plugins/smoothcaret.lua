-- mod-version:2 -- lite-xl 2.0
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"

config.plugins.smoothcaret = { rate = 0.65 }

local docview_update = DocView.update
function DocView:update()
  docview_update(self)

  if not self.caret then
    self.caret = { current = { x = 0, y = 0 }, target = { x = 0, y = 0 } }
  end  
  local c = self.caret
  self:move_towards(c.current, "x", c.target.x, config.plugins.smoothcaret.rate)
  self:move_towards(c.current, "y", c.target.y, config.plugins.smoothcaret.rate)
end

function DocView:draw_caret(x, y)
  local c = self.caret
  local lh = self:get_line_height()
  c.target.x = x
  c.target.y = y
  renderer.draw_rect(c.current.x, c.current.y, style.caret_width, lh, style.caret)
end
