-- mod-version:3 -- lite-xl:2.1

local core = require "core"
local View = require "core.view"
local DocView = require "core.docview"
local StatusView = require "core.statusview"
local RootView = require "core.rootview"
local command = require "core.command"
local common = require "core.common"
local style = require "core.style"
local config = require "core.config"
local keymap = require "core.keymap"

local HexEdit = {}

config.plugins.hexedit = common.merge({
  auto_detect_binary = true, -- If true, will attempt to autodetect binary files, and open HexViews if asked to open them.
  hex_area_width = 0.75      -- The percent of the area to be taken up by the hex representation.
}, config.plugins.hexedit)


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
  local lh = self:get_line_height()
  common.draw_text(font, style.normal, hex, "left", x, y, nil, lh)
  common.draw_text(font, style.normal, chars, "left", x + self.hex_area_width, y, nil, lh)
end


function HexView:draw_line_highlight(x, y, col1, col2)
  local gw, gpad = self:get_gutter_width()
  local lh = self:get_line_height()
  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  if col2 - col1 > 0 then
    renderer.draw_rect(x + gw + gpad + hex_byte_width * (col1 - 1), y, (col2 - col1) * hex_byte_width - character_width, lh, style.selection)
    renderer.draw_rect(x + self.hex_area_width + gw + gpad + character_width * (col1 - 1), y, (col2 - col1) * character_width, lh, style.selection)
  end
  renderer.draw_rect(x + gw + gpad + hex_byte_width * (col1 - 1) - 3, y, 1, lh, style.caret)
  renderer.draw_rect(x + gw + gpad + hex_byte_width * (col1 - 1) - 3, y + lh, hex_byte_width - character_width + 3, 1, style.caret)
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
  local line, col = math.floor((y - oy) / self:get_line_height()) + 1

  if x > self.hex_area_width then
    col = common.round((x - ox - gw - self.hex_area_width) / character_width) + 1
  else
    col = common.round((x - ox - gw) / hex_byte_width) + 1
  end
  
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
  self.hex_area_width = (self.size.x * config.plugins.hexedit.hex_area_width) - style.padding.x - gw - gpad

  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  local total_bytes_per_line = math.floor((self.hex_area_width - style.padding.x) / hex_byte_width)
  
  local lh = self:get_line_height()
  local ox, oy = self:get_content_offset()
  local x,y = ox + style.padding.x, oy + style.padding.y
  local line, hex, chars = 1, "", ""
  local visible_lower, visible_upper = 20, 126

  -- Only support single selection for now; multiple selections is starting to get complicated.
  local line1, col1, line2, col2 = self.doc:get_selection(true)
  local selection_start_offset = self:resolve_byte_position(line1, col1)
  local selection_end_offset = self:resolve_byte_position(line2, col2)

  core.push_clip_rect(self.position.x, self.position.y, self.size.x, self.size.y)
  renderer.draw_rect(self.position.x + self.hex_area_width + gw + gpad, self.position.y, 1, self.size.y, style.dim)
  local byte_lines = 1
  local draw_cursor = true
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


local function open_hex_view(doc, node)
    node = node or core.root_view:get_active_node_default()
    local view = HexView(doc)
    node:add_view(view)
    core.root_view.root_node:update_layout()
    return view
end

local function get_codepoint_and_width(string, offset)
  local top_four_bits = (string:byte(offset) & 240)
  local codepoint, width, n
  if     top_four_bits == 240 then codepoint, width = string:byte(offset) & 7, 4
  elseif top_four_bits == 224 then codepoint, width = string:byte(offset) & 15, 3
  elseif top_four_bits == 208 or top_four_bits == 192 then codepoint, width = string:byte(offset) & 15, 2
  else return string:byte(offset), 1 
  end
  for n = 1, width - 1 do codepoint = (codepoint << 6) | (string:byte(offset + n) & 63) end
  return codepoint, width
end

local function is_binary_doc(doc)
  local max_characters_to_examine = 64
  local string = ""
  for i, line in ipairs(doc.lines) do
    string = string .. line:sub(1, max_characters_to_examine - #string)
    if #string >= max_characters_to_examine then break end
  end
  -- Detect BOM as first character; assume non binary if BOM exists. Otherwise, check to if we have >128 characters, that *aren't* easily valid unicode, or ASCII control characters.
  if (
    (string:byte(1) == 239 and string:byte(2) == 187 and string:byte(3) == 191) or
    (string:byte(1) == 254 and string:byte(2) == 255) or
    (string:byte(1) == 255 and string:byte(2) == 254) or
    (string:byte(1) == 0 and string:byte(2) == 0 and string:byte(3) == 254 and string:byte(4) == 255) or
    (string:byte(1) == 43 and string:byte(2) == 47 and string:byte(3) == 118) or
    (string:byte(1) == 247 and string:byte(2) == 100 and string:byte(3) == 76) or
    (string:byte(1) == 221 and string:byte(2) == 115 and string:byte(3) == 102 and string:byte(4) == 115)
  )
  then
      return false
  end
  local i = 1
  while i < #string do
    local value = string:byte(i)
    if value <= 8 then return true end
    if value >= 128 then
      local codepoint, width = get_codepoint_and_width(string, i)
      if codepoint < 159  or codepoint > 1200000 then return true end
      i = i + width
    else
      i = i + 1
    end
  end
end

local old_rootview_open_doc = RootView.open_doc
function RootView:open_doc(doc)
  if not config.plugins.hexedit or not is_binary_doc(doc) then return old_rootview_open_doc(self, doc) end
  local node = self:get_active_node_default()
  for i, view in ipairs(node.views) do
    if view.doc == doc and view:is(HexView) then
      node:set_active_view(node.views[i])
      return view
    end
  end
  return open_hex_view(doc)
end
  
command.add(function(doc)
  return doc or (core.active_view and core.active_view.doc)
end, {
  ["hex-edit:open"] = function(doc)
    return open_hex_view(doc or core.active_view.doc)
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
