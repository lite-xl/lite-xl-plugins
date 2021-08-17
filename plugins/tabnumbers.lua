-- mod-version:2 -- lite-xl 2.0
local common = require "core.common"
local core = require "core"
local style = require "core.style"

-- quite hackish, but Node isn't normally public
local Node = getmetatable(core.root_view.root_node)
local draw_tabs = Node.draw_tabs

function Node:draw_tabs(...)
  draw_tabs(self, ...)

  for i, view in ipairs(self.views) do
    if i > 9 then break end

    local x, y, w, h = self:get_tab_rect(i)
    local number = tostring(i)
    local color = style.dim
    local title_width = style.font:get_width(view:get_name())
    local free_real_estate =
      math.min(math.max((w - title_width) / 2, style.padding.x), h)
    if view == self.active_view then
      color = style.accent
    end
    -- renderer.draw_rect(x, y + h - 1, free_real_estate, 1, color)
    common.draw_text(style.font, color, tostring(i), "center", x, y, free_real_estate, h)
  end
end
