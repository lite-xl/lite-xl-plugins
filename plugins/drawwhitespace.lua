local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"

-- originally written by luveti

config.whitespace_map = { [" "] = "·", ["\t"] = "»" }

local draw_line_text = DocView.draw_line_text

function DocView:draw_line_text(idx, x, y)
  draw_line_text(self, idx, x, y)

  local cl = self:get_cached_line(idx)
  local tx, ty = x, y + self:get_line_text_y_offset()
  local font = self:get_font()
  local color = style.whitespace or style.syntax.comment
  local map = config.whitespace_map

  for i = 1, #cl.text do
    local chr = cl.text:sub(i, i)
    local rep = map[chr]
    if rep then
      renderer.draw_text(font, rep, tx, ty, color)
    end
    tx = tx + font:get_width(chr)
  end
end

