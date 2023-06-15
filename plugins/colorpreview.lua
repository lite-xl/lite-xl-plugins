-- mod-version:3
local config = require "core.config"
local common = require "core.common"
local DocView = require "core.docview"


config.plugins.colorpreview = common.merge({
  enabled = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Color Preview",
    {
      label = "Enable",
      description = "Enable or disable the color preview feature.",
      path = "enabled",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.colorpreview)

local white = { common.color "#ffffff" }
local black = { common.color "#000000" }
local tmp = {}


local function draw_color_previews(self, line, x, y, ptn, base, nibbles)
  local text = self.doc.lines[line]
  local s, e = 0, 0

  while true do
    s, e = text:find(ptn, e + 1)
    if not s then break end

    local str = text:sub(s, e)
    local r, g, b, a = str:match(ptn)
    r, g, b = tonumber(r, base), tonumber(g, base), tonumber(b, base)
    a = tonumber(a or "", base)
    if a ~= nil then
      if base ~= 16 then
        a = a * 0xff
      end
    else
      a = 0xff
    end

    -- #123 becomes #112233
    if nibbles then
      r = r * 16
      g = g * 16
      b = b * 16
    end

    local x1 = x + self:get_col_x_offset(line, s)
    local x2 = x + self:get_col_x_offset(line, e + 1)
    local oy = self:get_line_text_y_offset()

    local text_color = math.max(r, g, b) < 128 and white or black
    tmp[1], tmp[2], tmp[3], tmp[4] = r, g, b, a

    local l1, _, l2, _ = self.doc:get_selection(true)

    if not (self.doc:has_selection() and line >= l1 and line <= l2) then
      renderer.draw_rect(x1, y, x2 - x1, self:get_line_height(), tmp)
      renderer.draw_text(self:get_font(), str, x1, y + oy, text_color)
    end
  end
end


local draw_line_text = DocView.draw_line_text

function DocView:draw_line_text(line, x, y)
  local lh = draw_line_text(self, line, x, y)
  if config.plugins.colorpreview.enabled then
    draw_color_previews(self, line, x, y,
      "#(%x%x)(%x%x)(%x%x)(%x?%x?)%f[%W]",
      16
    )
    -- support #fff css format
    draw_color_previews(self, line, x, y, "#(%x)(%x)(%x)%f[%W]", 16, true)
    draw_color_previews(self, line, x, y,
      "rgba?%((%d+)%D+(%d+)%D+(%d+)[%s,]-([%.%d]-)%s-%)",
      nil
    )
  end
  return lh
end
