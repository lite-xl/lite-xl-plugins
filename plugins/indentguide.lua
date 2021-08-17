-- mod-version:2 -- lite-xl 2.0
local style = require "core.style"
local config = require "core.config"
local DocView = require "core.docview"


local function get_line_spaces(doc, idx, dir)
  local text = doc.lines[idx]
  if not text then
    return 0
  end
  local s, e = text:find("^%s*")
  if e == #text then
    return get_line_spaces(doc, idx + dir, dir)
  end
  local n = 0
  for i = s, e do
    n = n + (text:byte(i) == 9 and config.indent_size or 1)
  end
  return n
end


local function get_line_indent_guide_spaces(doc, idx)
  if doc.lines[idx]:find("^%s*\n") then
    return math.max(
      get_line_spaces(doc, idx - 1, -1),
      get_line_spaces(doc, idx + 1,  1))
  end
  return get_line_spaces(doc, idx)
end


local draw_line_text = DocView.draw_line_text

function DocView:draw_line_text(idx, x, y)
  local spaces = get_line_indent_guide_spaces(self.doc, idx)
  local w = math.ceil(1 * SCALE)
  local h = self:get_line_height()
  local sspaces = ""
  local font = self:get_font()
  local ss = font:subpixel_scale()
  for _ = 0, spaces - 1, config.indent_size do
    local color = style.guide or style.selection
    local sw = font:get_width_subpixel(sspaces) / ss
    renderer.draw_rect(x + sw, y, w, h, color)
    sspaces = sspaces .. (' '):rep(config.indent_size)
  end
  draw_line_text(self, idx, x, y)
end
