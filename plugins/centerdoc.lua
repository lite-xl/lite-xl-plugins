-- mod-version:2 -- lite-xl 2.0
local config = require "core.config"
local DocView = require "core.docview"


local draw_line_gutter = DocView.draw_line_gutter
local get_gutter_width = DocView.get_gutter_width


function DocView:draw_line_gutter(idx, x, y, width)
  local real_gutter_width = get_gutter_width(self)
  local offset = self:get_gutter_width() - real_gutter_width * 2
  draw_line_gutter(self, idx, x + offset, y, real_gutter_width)
end


function DocView:get_gutter_width()
  local real_gutter_width = get_gutter_width(self)
  local width = real_gutter_width + self:get_font():get_width("n") * config.line_limit
  return math.max((self.size.x - width) / 2, real_gutter_width)
end
