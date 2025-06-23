-- mod-version:4
local style = require "core.style"
local DocView = require "core.docview"

-- originally written by luveti

local function draw_box(x, y, w, h, color)
  local r = renderer.draw_rect
  local s = math.ceil(SCALE)
  r(x, y, w, s, color)
  r(x, y + h - s, w, s, color)
  r(x, y + s, s, h - s * 2, color)
  r(x + w - s, y + s, s, h - s * 2, color)
end


local draw_line_body = DocView.draw_line_body

function DocView:draw_line_body(vline, x, y)
  local line_height = draw_line_body(self, vline, x, y)
  local line1, col1, line2, col2 = self:get_selection(true)
  if line1 == line2 and col1 ~= col2 then
    local selection = self.doc:get_text(line1, col1, line2, col2)
    if not selection:match("^%s+$") then
      local lh = self:get_line_height()
      local selected_text = self.doc.lines[line1]:usub(col1, col2 - 1)
      if #selected_text > 0 then

        local default_font = self:get_font()
        local w = 0
        local chunks = {}
        for _, text, style, type in self:each_vline_token(vline) do
          w = w + (style.font or default_font):get_width(text)
          table.insert(chunks, text)
        end
        
        local sline1 = self:get_dline(vline, 1)
        local sline2 = self:get_dline(vline, self:get_vline_length(vline))
        for sline = sline1, sline2 do
          local current_line_text = self.doc.lines[sline]
          local last_col = 1
          while true do
            local start_col, end_col = current_line_text:ufind(
              selected_text, last_col, true
            )
            if start_col == nil then break end
            -- don't draw box around the selection
            if sline ~= line1 or start_col ~= col1 then
              local vline1, vcol1 = self:get_vline(sline, start_col)
              local vline2, vcol2 = self:get_vline(sline, end_col + 1)
              if vline >= vline1 and vline <= vline2 then 
                local x1, x2
                if vline == vline1 then
                  x1 = x + self:get_vline_position(vline1, vcol1)
                else
                  x1 = x
                end
                if vline == vline2 then
                  x2 = x + self:get_vline_position(vline2, vcol2)
                else
                  x2 = x + self:get_vline_width(vline) 
                end
                local color = style.selectionhighlight or style.syntax.comment
                draw_box(x1, y, x2 - x1, lh, color)
              end
            end
            last_col = end_col + 1
          end
        end
        
      end
    end
  end
  return line_height
end

