-- mod-version:3 -- lite-xl:2.1

local core = require "core"
local View = require "core.view"
local DocView = require "core.docview"
local command = require "core.command"
local style = require "core.style"
local config = require "core.config"

local HexEdit = {}

local HexView = DocView:extend()


function HexView:get_name()
  return "Hex View - " .. self.doc.filename
end

function HexView:new(doc)
  HexView.super.new(self, doc)
end



function HexView:get_scrollable_size()
  if not config.scroll_past_end then
    return self:get_line_height() * (#self.doc.lines) + style.padding.y * 2
  end
  return self:get_line_height() * (#self.doc.lines - 1) + self.size.y
end

local hex_characters = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" }

function HexView:draw_line(x, y, hex, chars)
  local font = self:get_font()
  renderer.draw_text(font, hex, x, y, style.normal)
  renderer.draw_text(font, chars, x + self.hex_area_width, y, style.normal)
end


function HexView:draw_line_highlight(x, y, col1, col2)
  local lh = self:get_line_height()
  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  renderer.draw_rect(x + hex_byte_width * (col1 - 1), y, (col2 - col1) * hex_byte_width, lh, style.selection)
  renderer.draw_rect(x + self.hex_area_width + character_width * (col1 - 1), y, (col2 - col1) * character_width, lh, style.selection)
end


function HexView:draw()
  self:draw_background(style.background)
  self.hex_area_width = (self.size.x * 3 / 4) - style.padding.x

  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  local total_bytes_per_line = math.floor((self.hex_area_width - style.padding.x) / hex_byte_width)
  
  local lh = self:get_line_height()
  local ox, oy = self:get_content_offset()
  local x,y = ox + style.padding.x, oy + style.padding.y
  local line, hex, chars = 1, "", ""
  local visible_lower, visible_upper = 20, 127

  local start_line, start_col = 1, 1

  core.push_clip_rect(self.position.x, self.position.y, self.size.x, self.size.y)
  renderer.draw_rect(self.position.x + self.hex_area_width, self.position.y, 1, self.size.y, style.dim)
  for line = 1, #self.doc.lines do
    for offset = 1, #self.doc.lines[line] do
      local value = self.doc.lines[line]:byte(offset)
      local upper = math.floor(value / 16) + 1
      local lower = (value % 16) + 1
      hex = hex .. hex_characters[upper] .. hex_characters[lower] .. " "
      chars = chars .. (value >= visible_lower and value <= visible_upper and string.char(value) or ".")
      if #hex >= total_bytes_per_line * 3 then

      
        local selection_start, selection_end
        for lidx, line1, col1, line2, col2 in self.doc:get_selections(true) do
          if line1 <= line and line2 >= line then
            if line1 < line then
              selection_start = 1
            else
              selection_start = (start_col - col1) + 1
            end
            if line2 > line then
              selection_end = total_bytes_per_line
            else
              selection_end = col2 - offset
            end
          end
        end
        print(selection_start, selection_end)

        if selection_start and selection_end then
          self:draw_line_highlight(x, y, selection_start, selection_end)
        end
        self:draw_line(x, y, hex, chars)
        y = y + lh
        hex, chars = "", ""
        start_line, start_col = line, offset


        
      end
    end
  end
  self:draw_line(x, y, hex, chars)
  self:draw_scrollbar()
  core.pop_clip_rect()
end


HexEdit.view = HexView

command.add(function()
  return core.active_view and core.active_view.doc
end, {
  ["hex-edit:open"] = function()
    local node = core.root_view:get_active_node_default()
    print(core.active_view.doc)
    local view = HexView(core.active_view.doc)
    node:add_view(view)
    core.root_view.root_node:update_layout()
    return view
  end
})

return HexEdit
