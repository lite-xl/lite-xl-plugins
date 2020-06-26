local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"
local command = require "core.command"

-- originally written by luveti

config.whitespace_map = { [" "] = "·", ["\t"] = "»" }

local visible = true

local draw_line_text = DocView.draw_line_text

function DocView:draw_line_text(idx, x, y)
  draw_line_text(self, idx, x, y)
  if not visible then return end

  local text = self.doc.lines[idx]
  local tx, ty = x, y + self:get_line_text_y_offset()
  local font = self:get_font()
  local color = style.whitespace or style.syntax.comment
  local map = config.whitespace_map

  for i = 1, #text do
    local chr = text:sub(i, i)
    local rep = map[chr]
    if rep then
      renderer.draw_text(font, rep, tx, ty, color)
    end
    tx = tx + font:get_width(chr)
  end
end

command.add("core.docview", {
  ["drawwhitespace:toggle"] = function() visible = not visible end,
  ["drawwhitespace:no"]     = function() visible = false       end,
  ["drawwhitespace:yes"]    = function() visible = true        end,
})
