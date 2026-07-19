-- mod-version:3
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"

config.plugins.selectionhighlight = common.merge({
  opacity = 255,
  thickness = 1,
  use_scale = true,
  config_spec = {
    name = "Selection Highlight",
    {
      label = "Highlight Box Opacity",
      description = "Define the how opaque the highlight box is.",
      path = "opacity",
      type = "number",
      default = 255,
      min = 0,
      max = 255
    },
    {
      label = "Highlight Box Thickness",
      description = "Thickness of highlight box.",
      path = "thickness",
      type = "number",
      default = 1,
      min = 1,
      max = 10
    },
    {
      label = "Use SCALE Value",
      description = "Increase thickness of highlight box acording to the SCALE value.",
      path = "use_scale",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.selectionhighlight)

-- originally written by luveti

local function draw_box(x, y, w, h, color, thickness, use_scale)
  local r = renderer.draw_rect
  local t = use_scale and math.ceil(SCALE) * thickness or thickness

  r(x, y, w, t, color)
  r(x, y + h - t, w, t, color)
  r(x, y + t, t, h - t * 2, color)
  r(x + w - t, y + t, t, h - t * 2, color)
end


local draw_line_body = DocView.draw_line_body

function DocView:draw_line_body(line, x, y)
  local line_height = draw_line_body(self, line, x, y)
  local line1, col1, line2, col2 = self.doc:get_selection(true)
  if line1 == line2 and col1 ~= col2 then
    local selection = self.doc:get_text(line1, col1, line2, col2)
    if not selection:match("^%s+$") then
      local lh = self:get_line_height()
      local selected_text = self.doc.lines[line1]:sub(col1, col2 - 1)
      local current_line_text = self.doc.lines[line]
      local last_col = 1
      while true do
        local start_col, end_col = current_line_text:find(
          selected_text, last_col, true
        )
        if start_col == nil then break end
        -- don't draw box around the selection
        if line ~= line1 or start_col ~= col1 then
          local x1 = x + self:get_col_x_offset(line, start_col)
          local x2 = x + self:get_col_x_offset(line, end_col + 1)

          local color = style.selectionhighlight or style.syntax.comment
          local color_modified = {}
          for idx, val in pairs(color) do
             color_modified[idx] = val
          end
          color_modified[4] = config.plugins.selectionhighlight.opacity

          local thickness = config.plugins.selectionhighlight.thickness
          local use_scale = config.plugins.selectionhighlight.use_scale
          draw_box(x1, y, x2 - x1, lh, color_modified, thickness, use_scale)
        end
        last_col = end_col + 1
      end
    end
  end
  return line_height
end

