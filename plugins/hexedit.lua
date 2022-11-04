-- mod-version:3 -- lite-xl:2.1

local core = require "core"
local View = require "core.view"
local DocView = require "core.docview"
local StatusView = require "core.statusview"
local command = require "core.command"
local common = require "core.common"
local style = require "core.style"
local config = require "core.config"
local keymap = require "core.keymap"

local HexEdit = {}

local HexView = DocView:extend()


function HexView:get_name()
  return "Hex View - " .. self.doc.filename
end

function HexView:new(doc)
  HexView.super.new(self, doc)
end

local hex_characters = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" }
local function convert_to_hex(integer, min_amount)
  min_amount = min_amount or integer
  if min_amount <= 255 then return hex_characters[((integer >> 4) & 0xF) + 1] .. hex_characters[((integer & 0xF)) + 1] end
  if min_amount <= 65535 then return hex_characters[((integer >> 12) & 0xF) + 1] .. hex_characters[((integer >> 8) & 0xF) + 1] .. hex_characters[((integer >> 4) & 0xF) + 1] .. hex_characters[((integer & 0xF)) + 1] end
  return 
    hex_characters[((integer >> 28) & 0xF) + 1] .. hex_characters[((integer >> 24) & 0xF) + 1] .. hex_characters[((integer >> 20) & 0xF) + 1] .. hex_characters[((integer >> 16) & 0xF) + 1] ..
    hex_characters[((integer >> 12) & 0xF) + 1] .. hex_characters[((integer >> 8) & 0xF) + 1] .. hex_characters[((integer >> 4) & 0xF) + 1] .. hex_characters[((integer & 0xF)) + 1]
end


function HexView:get_gutter_width()
  local padding = style.padding.x * 2
  return self:get_font():get_width("0xFFFFFF"), padding
end


function HexView:get_scrollable_size()
  if not config.scroll_past_end then
    return self:get_line_height() * (#self.doc.lines) + style.padding.y * 2
  end
  return self:get_line_height() * (#self.doc.lines - 1) + self.size.y
end


function HexView:draw_line(x, y, hex, chars)
  local font = self:get_font()
  renderer.draw_text(font, hex, x, y, style.normal)
  renderer.draw_text(font, chars, x + self.hex_area_width, y, style.normal)
end


function HexView:draw_line_highlight(x, y, col1, col2)
  local gw, gpad = self:get_gutter_width()
  local lh = self:get_line_height()
  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  renderer.draw_rect(x + gw + gpad + hex_byte_width * (col1 - 1), y, (col2 - col1) * hex_byte_width - character_width, lh, style.selection)
  renderer.draw_rect(x + self.hex_area_width + gw + gpad + character_width * (col1 - 1), y, (col2 - col1) * character_width, lh, style.selection)
end


function HexView:resolve_byte_position(line, col)
  local total = 0
  for i = 1, #self.doc.lines do
    if line == i then return total + (col - 1) end
    total = total + #self.doc.lines[i]
  end
  return total
end

function HexView:get_line_byte_position(offset)
  local total = 0
  for i = 1, #self.doc.lines do
    if total + #self.doc.lines[i] >= offset then
      return i, (offset - total) + 1
    end
    total = total + #self.doc.lines[i]
  end
  return #self.doc.lines, #self.doc.lines[#self.doc.lines]
end


function HexView:resolve_screen_position(x, y)
  local gw, gpad = self:get_gutter_width()
  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  local total_bytes_per_line = math.floor((self.hex_area_width - style.padding.x) / hex_byte_width)


  local ox, oy = self:get_line_screen_position(1)
  local line = math.floor((y - oy) / self:get_line_height()) + 1
  local col = common.round((x - ox - gw) / hex_byte_width) + 1
  
  return self:get_line_byte_position((line - 1) * total_bytes_per_line + col)
end

function HexView:draw_line_gutter(line, x, y, width)
  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  local total_bytes_per_line = math.floor((self.hex_area_width - style.padding.x) / hex_byte_width)
  local color = style.line_number
  x = x + style.padding.x
  local lh = self:get_line_height()
  common.draw_text(self:get_font(), color, "0x" .. convert_to_hex((line - 1) * total_bytes_per_line, 16667216), "right", x, y, width, lh)
  return lh
end

function HexView:draw()
  self:draw_background(style.background)
  local gw, gpad = self:get_gutter_width()
  self.hex_area_width = (self.size.x * 3 / 4) - style.padding.x - gw - gpad

  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  local total_bytes_per_line = math.floor((self.hex_area_width - style.padding.x) / hex_byte_width)
  
  local lh = self:get_line_height()
  local ox, oy = self:get_content_offset()
  local x,y = ox + style.padding.x, oy + style.padding.y
  local line, hex, chars = 1, "", ""
  local visible_lower, visible_upper = 20, 127

  -- Only support single selection for now; multiple selections is starting to get complicated.
  local line1, col1, line2, col2 = self.doc:get_selection(true)
  local selection_start_offset = self:resolve_byte_position(line1, col1)
  local selection_end_offset = self:resolve_byte_position(line2, col2)

  core.push_clip_rect(self.position.x, self.position.y, self.size.x, self.size.y)
  renderer.draw_rect(self.position.x + self.hex_area_width + gw + gpad, self.position.y, 1, self.size.y, style.dim)
  local byte_lines = 1
  for line = 1, #self.doc.lines do
    for offset = 1, #self.doc.lines[line] do
      local value = self.doc.lines[line]:byte(offset)
      hex = hex .. convert_to_hex(value) .. " "
      chars = chars .. (value >= visible_lower and value <= visible_upper and string.char(value) or ".")
      if #hex >= total_bytes_per_line * 3 then
        if selection_start_offset and (byte_lines * total_bytes_per_line) >= selection_start_offset and ((byte_lines - 1) * total_bytes_per_line) <= selection_end_offset then
          local byte_start = math.max(selection_start_offset - ((byte_lines-1) * total_bytes_per_line), 0) + 1
          local byte_end = math.min(selection_end_offset - ((byte_lines-1) * total_bytes_per_line), total_bytes_per_line) + 1
          self:draw_line_highlight(x, y, byte_start, byte_end) 
        end
        self:draw_line_gutter(byte_lines, x, y, gw)
        self:draw_line(x + gw + gpad, y, hex, chars)
        y = y + lh
        hex, chars = "", ""
        byte_lines = byte_lines + 1
      end
    end
  end
  if selection_start_offset and (byte_lines * total_bytes_per_line) >= selection_start_offset and ((byte_lines - 1) * total_bytes_per_line) <= selection_end_offset then
    local byte_start = math.max(selection_start_offset - ((byte_lines-1) * total_bytes_per_line), 0) + 1
    local byte_end = math.min(selection_end_offset - ((byte_lines-1) * total_bytes_per_line), total_bytes_per_line) + 1
    self:draw_line_highlight(x, y, byte_start, byte_end) 
  end
  self:draw_line_gutter(byte_lines, x, y, gw)
  self:draw_line(x + gw + gpad, y, hex, chars)
  self:draw_scrollbar()
  core.pop_clip_rect()
end


HexEdit.view = HexView

local function predicate_hexview()
  return core.active_view and core.active_view:is(HexView)
end

local function get_selection(doc)
  local line1, col1, line2, col2 = doc:get_selection(true)
  local length = 0
  local str = ""
  for i = line1, line2 do
    local s = i == line1 and col1 or 1
    local e = i == line2 and col2 or #doc.lines[i]
    str = str .. doc.lines[i]:sub(s,e - 1)
  end
  return str
end

local function get_selection_integer(doc)
  local chars = get_selection(doc)
  if #chars == 1 then
    return string.byte(chars, 1), "char"
  end
  if #chars == 2 then
    return ((string.byte(chars, 1) << 8) | string.byte(chars, 2)), "short"
  end
  if #chars == 4 then
    return ((string.byte(chars, 1) << 24) | (string.byte(chars, 2) << 16) | (string.byte(chars, 3) << 8) | string.byte(chars, 4)), "int"
  end
  if #chars == 8 then
    return ((string.byte(chars, 1) << 56) | (string.byte(chars, 2) << 48) | (string.byte(chars, 3) << 40) | string.byte(chars, 4) << 32 |
           (string.byte(chars, 5) << 24) | (string.byte(chars, 6) << 16) | (string.byte(chars, 7) << 8) | string.byte(chars, 8)), "long long"
  end
  return nil
end

core.status_view:add_item({
  predicate = function() 
    local is_hexview = predicate_hexview()
    local length = is_hexview and #get_selection(core.active_view.doc)
    return is_hexview and (length == 1 or length == 2 or length == 4 or length == 8)
  end,
  name = "hex:file",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    local hv = core.active_view
    local line1, col1, line2, col2 = hv.doc:get_selection(true)
    local value, type = get_selection_integer(hv.doc)
    return {
      style.text,
      style.font,
      string.format("%s %d", type, value)
    }
  end
})
  
command.add(function(doc)
  return doc or (core.active_view and core.active_view.doc)
end, {
  ["hex-edit:open"] = function(doc)
    doc = doc or core.active_view.doc
    local node = core.root_view:get_active_node_default()
    local view = HexView(doc)
    node:add_view(view)
    core.root_view.root_node:update_layout()
    return view
  end
})

local has_treeview, treeview = pcall(require, "plugins.treeview")
if has_treeview then
  command.add(function(doc)
    return treeview.hovered_item and treeview.hovered_item.type == "file"
  end, {
    ["treeview:open-hex"] = function()
      command.perform("hex-edit:open", core.open_doc(treeview.hovered_item.abs_filename))
    end
  })
  treeview.contextmenu:register(
    function() return treeview.hovered_item and treeview.hovered_item.type == "file" end,
    { { text = "Open as Hex", command = "treeview:open-hex" } }
  )
end

keymap.add({
  ["ctrl+h"] = "hex-edit:open"
})

return HexEdit
