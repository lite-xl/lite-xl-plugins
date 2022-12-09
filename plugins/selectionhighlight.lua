-- mod-version:3
local style = require "core.style"
local DocView = require "core.docview"

-- originally written by luveti

-- Workaround for bug in Lite XL 2.1
-- Remove this when b029f5993edb7dee5ccd2ba55faac1ec22e24609 is in a release
local function get_selection(doc, sort)
  local line1, col1, line2, col2 = doc:get_selection_idx(doc.last_selection)
  if line1 then
    return doc:get_selection_idx(doc.last_selection, sort)
  else
    return doc:get_selection_idx(1, sort)
  end
end

local function draw_box(x, y, w, h, color)
  local r = renderer.draw_rect
  local s = math.ceil(SCALE)
  r(x, y, w, s, color)
  r(x, y + h - s, w, s, color)
  r(x, y + s, s, h - s * 2, color)
  r(x + w - s, y + s, s, h - s * 2, color)
end


local draw_line_body = DocView.draw_line_body

function DocView:draw_line_body(line, x, y)
  local line_height = draw_line_body(self, line, x, y)
  local line1, col1, line2, col2 = get_selection(self.doc, true)
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
          draw_box(x1, y, x2 - x1, lh, color)
        end
        last_col = end_col + 1
      end
    end
  end
  return line_height
end

-- Special thanks to Adam(aethy)
-- for writing code which served as a guide

--- This added feature displays selection highlights in/on the scrollbar

local old_draw_docview_scrollbar = DocView.draw_scrollbar

function DocView:draw_scrollbar()
  old_draw_docview_scrollbar(self)
  local scrollbar = self.v_scrollbar

  local mw = 5  --marker width
  local mh = 8  -- marker height
  local cmh = 4  --current selection marker height
  local cm_color =  {common.color "#DA70D6"} --current selection marker color
  
  local line1, col1, line2, col2 = get_selection(self.doc, true)
  
  if line1 == line2 and col1 ~= col2 then
    local selection = self.doc:get_text(line1, col1, line2, col2)
    
    if self.doc and scrollbar then
      local x,y,w,h = scrollbar:get_track_rect()
      
      for line, line_text in pairs(self.doc.lines) do 
        --draw this marker to show current selection
        if line == line1 then
          local percentage_start = line / #self.doc.lines
          renderer.draw_rect(x, percentage_start * h, w, cmh, cm_color)
        end
        --draw this marker to show occurrences of selection
        if line_text:match(selection) and line ~= line1 then 
          local percentage_start = line / #self.doc.lines
          renderer.draw_rect(x+(w*0.5)-mw*0.5, percentage_start * h, mw, mh, style.accent)
        end  
      end
    end
   end
end

