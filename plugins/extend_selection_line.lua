-- mod-version:3
local DocView = require "core.docview"
local style = require "core.style"

local draw_line_body = DocView.draw_line_body
function DocView:draw_line_body(line, x, y)
  local line_height = draw_line_body(self, line, x, y)
  local lh = self:get_line_height()
  for _, line1, _, line2, _ in self.doc:get_selections(true) do
    if line >= line1 and line < line2 and line1 ~= line2 then
      -- draw selection from the end of the line to the end of the available space
      local x1 = x + self:get_col_x_offset(line, #self.doc.lines[line])
      local x2 = x + self.scroll.x + self.size.x
      if x2 > x1 then
        renderer.draw_rect(x1, y, x2 - x1, lh, style.selection)
      end
    end
  end
  return line_height
end
