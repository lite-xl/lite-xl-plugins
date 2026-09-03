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
  auto_detect_binary = true,  -- If true, will attempt to autodetect binary files, and open HexViews if asked to open them.
  hex_area_width = 0.75,      -- The percent of the area to be taken up by the hex representation.
  line_multiple = nil,        -- If set, forces the offsets to wrap to floor of this multiple. (i.e. if your display has lines of 128, and you set a multiple of 50, this would wrap to 100)
  bytes_per_line = nil,       -- Forces a maximum amount of bytes per line.
  colors = {                  -- Sets the colors of various byte sequences. If set to nil, disables coloring.
    utf8 = style.caret,
    control = style.error,
    ascii = style.accent,
    unknown = style.text
  }
}, config.plugins.hexedit)


local HexView = DocView:extend()

function HexView:get_name()
  return "Hex View - " .. self.doc.filename
end

-- Every 120 bytes 
function HexView:new(doc)
  HexView.super.new(self, doc)
  self.bytes_per_cache_line = 240
  self.byte_cache = {}
  self.bytes_per_display_line = nil
end

function HexView:invalidate_cache(start)
  
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

local function get_utf8_codepoint_and_width(string, offset)
  local value = string:byte(offset)
  if not value then return nil end
  local top_four_bits = value & 240
  local codepoint, width, n
  if     top_four_bits == 240 then codepoint, width = value & 7, 4
  elseif top_four_bits == 224 then codepoint, width = value & 15, 3
  elseif top_four_bits == 208 or top_four_bits == 192 then codepoint, width = value & 15, 2
  elseif value >= 128 then return nil
  else return value, 1 
  end
  if offset - 1 + width > #string then return nil, width end
  for n = 1, width - 1 do 
    local value = string:byte(offset + n)
    if value & 192 ~= 128 then return nil end
    codepoint = (codepoint << 6) | (value & 63) 
  end
  return codepoint, width
end


function HexView:get_gutter_width()
  local padding = style.padding.x * 2
  return self:get_font():get_width("0xFFFFFF"), padding
end


function HexView:get_scrollable_size()
  local estimated_lines = self:get_estimated_lines((self.scroll.y + self.size.y * 2) / self:get_line_height() * (self.bytes_per_display_line or 80))
  if not config.scroll_past_end then
    return self:get_line_height() * estimated_lines + style.padding.y * 2
  end
  return self:get_line_height() * estimated_lines + self.size.y
end

local function classify_byte(str, offset)
  local value = str:byte(offset)
  if value < 32 then return "control", 1 end
  if value < 128 then return "ascii", 1 end
  local codepoint, width = get_utf8_codepoint_and_width(str, offset)
  if not width then return "unknown", 1 end
  return "utf8", width
end

local function tokenize_line_iter(state, i)
  if state[3] == nil then return nil end
  if i == 0 then -- handle open utf8 byte
    
  end
  local original = state[3]
  local last_type, new_type, length
  local k = original
  while k < #state[1] do
    new_type, length = classify_byte(state[1], k)
    if last_type and new_type ~= last_type then 
      state[3] = k
      
      return i + 1, last_type, state[1]:sub(original, k - 1) 
    end
    last_type = new_type
    k = k + length
  end
  state[3] = nil
  return i + 1, new_type, state[1]:sub(original)
end

local function tokenize_line(line, previous_four_bytes)
  local state = { line, previous_four_bytes, 1 }
  return tokenize_line_iter, state, 0
end

local visible_lower, visible_upper = 20, 126
local function convert_bytes_to_chars_and_hex(bytes)
  local hex, chars = "", ""
  for i = 1, #bytes do
    local value = bytes:byte(i)
    hex = hex .. convert_to_hex(value) .. " "
    chars = chars .. (value >= visible_lower and value <= visible_upper and string.char(value) or ".")
  end
  return hex, chars
end

function HexView:draw_line(x, y, bytes, previous_four_bytes)
  local font = self:get_font()
  local lh = self:get_line_height()
  local colors = config.plugins.hexedit.colors
  if colors then
    local x1, x2 = x, x + self.hex_area_width
    for i, type, group in tokenize_line(bytes, previous_four_bytes) do
      local hex, chars = convert_bytes_to_chars_and_hex(group)
      x1 = common.draw_text(font, colors[type], hex, "left", x1, y, nil, lh)
      x2 = common.draw_text(font, colors[type], chars, "left", x2, y, nil, lh)
    end
  else
    local hex, chars = convert_bytes_to_chars_and_hex(bytes)
    common.draw_text(font, style.normal, hex, "left", x, y, nil, lh)
    common.draw_text(font, style.normal, chars, "left", x + self.hex_area_width, y, nil, lh)
  end
end


function HexView:draw_line_highlight(x, y, col1, col2)
  local gw, gpad = self:get_gutter_width()
  local lh = self:get_line_height()
  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  local sel_hex_start = x + gw + gpad + hex_byte_width * (col1 - 1)
  local sel_char_start = x + self.hex_area_width + gw + gpad + character_width * (col1 - 1)
  if col2 - col1 > 0 then
    renderer.draw_rect(sel_hex_start, y, (col2 - col1) * hex_byte_width - character_width, lh, style.selection)
    renderer.draw_rect(sel_char_start, y, (col2 - col1) * character_width, lh, style.selection)
  end
  renderer.draw_rect(sel_hex_start - 3, y, 1, lh, style.caret)
  renderer.draw_rect(sel_hex_start - 3, y + lh, hex_byte_width - character_width + 3, 1, style.caret)

  renderer.draw_rect(sel_char_start, y, 1, lh, style.caret)
  renderer.draw_rect(sel_char_start, y + lh, character_width + 3, 1, style.caret)
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

  local start_line, start_col = 1,1
  if #self.byte_cache > 0 then
    local idx = math.floor(offset / self.bytes_per_cache_line) + 1
    if not self.byte_cache[idx] then idx = #self.byte_cache end
    start_line, start_col, total = self.byte_cache[idx][1], self.byte_cache[idx][2], (idx - 1) * self.bytes_per_cache_line
  end
  
  for i = start_line, #self.doc.lines do
    local line_length = #self.doc.lines[i] - (start_col - 1)
    for idx = 1, math.floor((total + line_length) / self.bytes_per_cache_line) - math.floor(total / self.bytes_per_cache_line) + 1 do
      if not self.byte_cache[idx] then self.byte_cache[idx] = { i, start_col + (idx - 1) * self.bytes_per_cache_line } end
    end
    if total + line_length >= offset then return i, (offset - total) + 1 end
    total, start_col = total + line_length, 1
  end
  return #self.doc.lines, #self.doc.lines[#self.doc.lines]
end

function HexView:get_estimated_lines(offset)
  self:get_line_byte_position(offset)
  return (#self.byte_cache * self.bytes_per_cache_line) / (self.bytes_per_display_line or 80)
end

function HexView:get_content_offset()
  local y = common.round(self.position.y - self.scroll.y)
  return self.position.x, y
end

function HexView:resolve_screen_position(x, y)
  local gw, gpad = self:get_gutter_width()
  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  
  local ox, oy = self:get_line_screen_position(1)
  local line, col = math.floor((y - oy) / self:get_line_height()) + 1

  if x > self.hex_area_width then
    col = common.round((x - ox - gw - self.hex_area_width) / character_width) + 1
  else
    col = common.round((x - ox - gw) / hex_byte_width) + 1
  end
  
  return self:get_line_byte_position((line - 1) * self.bytes_per_display_line + col)
end

function HexView:draw_line_gutter(line, x, y, width)
  local color = style.line_number
  x = x + style.padding.x
  local lh = self:get_line_height()
  common.draw_text(self:get_font(), color, "0x" .. convert_to_hex((line - 1) * self.bytes_per_display_line, 16667216), "right", x, y, width, lh)
  return lh
end

function HexView:draw()
  self:draw_background(style.background)
  local gw, gpad = self:get_gutter_width()
  self.hex_area_width = (self.size.x * config.plugins.hexedit.hex_area_width) - style.padding.x - gw - gpad

  local character_width = self:get_font():get_width(" ")
  local hex_byte_width = character_width * 3
  self.bytes_per_display_line = math.floor((self.hex_area_width - style.padding.x) / hex_byte_width)
  if config.plugins.hexedit.line_multiple and (self.bytes_per_display_line / config.plugins.hexedit.line_multiple) > 1 then
    self.bytes_per_display_line = self.bytes_per_display_line - self.bytes_per_display_line % config.plugins.hexedit.line_multiple
  end
  self.bytes_per_display_line = math.min(self.bytes_per_display_line, config.plugins.hexedit.bytes_per_line or math.huge)
  
  local lh = self:get_line_height()
  local ox, oy = self:get_content_offset()
  local x,y = ox + style.padding.x, oy + style.padding.y
  local line, bytes, prev_bytes = 1, "", ""

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
      bytes = bytes .. self.doc.lines[line]:sub(offset, offset)
      if #bytes >= self.bytes_per_display_line then
        if selection_start_offset and (byte_lines * self.bytes_per_display_line) >= selection_start_offset and ((byte_lines - 1) * self.bytes_per_display_line) <= selection_end_offset then
          local byte_start = math.max(selection_start_offset - ((byte_lines-1) * self.bytes_per_display_line), 0) + 1
          local byte_end = math.min(selection_end_offset - ((byte_lines-1) * self.bytes_per_display_line), self.bytes_per_display_line) + 1
          self:draw_line_highlight(x, y, byte_start, byte_end) 
        end
        self:draw_line_gutter(byte_lines, x, y, gw)
        self:draw_line(x + gw + gpad, y, bytes, prev_bytes and prev_bytes:sub(#prev_bytes - 4))
        y = y + lh
        prev_bytes, bytes = bytes, ""
        byte_lines = byte_lines + 1
      end
    end
  end
  if selection_start_offset and (byte_lines * self.bytes_per_display_line) >= selection_start_offset and ((byte_lines - 1) * self.bytes_per_display_line) <= selection_end_offset then
    local byte_start = math.max(selection_start_offset - ((byte_lines-1) * self.bytes_per_display_line), 0) + 1
    local byte_end = math.min(selection_end_offset - ((byte_lines-1) * self.bytes_per_display_line), self.bytes_per_display_line) + 1
    self:draw_line_highlight(x, y, byte_start, byte_end) 
  end
  self:draw_line_gutter(byte_lines, x, y, gw)
  self:draw_line(x + gw + gpad, y, bytes, prev_bytes:sub(#prev_bytes - 4))
  self:draw_scrollbar()
  core.pop_clip_rect()
end


HexEdit.view = HexView

local function predicate_hexview()
  return core.active_view and core.active_view:is(HexView)
end


local function get_selection(doc)
  return doc:get_text(doc:get_selection(true))
end

local function get_integer(chars)
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
  predicate = predicate_hexview,
  name = "hex:offset",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    local hv = core.active_view
    local line1, col1, line2, col2 = hv.doc:get_selection(true)
    local selection
    local offset1 = hv:resolve_byte_position(line1, col1)
    local t = {
      style.text,
      style.font,
      string.format("offset 0x%s (%d)", convert_to_hex(offset1), offset1)
    }
    if line1 ~= line2 or col1 ~= col2  then
      local offset2 = hv:resolve_byte_position(line2, col2)
      selection = get_selection(core.active_view.doc)
      table.insert(t, style.text)
      table.insert(t, style.font)
      table.insert(t, StatusView.separator2)
      
      table.insert(t, style.text)
      table.insert(t, style.font)
      table.insert(t, string.format("selection 0x%s (%d) bytes", convert_to_hex(offset2 - offset1), offset2 - offset1))

      
      local value, type = get_integer(selection)
      if value and type then 
        table.insert(t, style.text)
        table.insert(t, style.font)
        table.insert(t, StatusView.separator2)
        
        table.insert(t, style.text)
        table.insert(t, style.font)
        table.insert(t, string.format("%s %d %s", type, value, value >= visible_lower and value <= visible_upper and ("'" .. selection .. "'") or ""))
      end
    else
      line1, col1 = hv:get_line_byte_position(offset1)
      line2, col2 = hv:get_line_byte_position(offset1 + 1)
      local char = hv.doc:get_text(line1, col1, line2, col2) 
      if #char > 0 then
        local value = char:byte(1)
        table.insert(t, style.text)
        table.insert(t, style.font)
        table.insert(t, StatusView.separator2)
        
        table.insert(t, style.text)
        table.insert(t, style.font)
        table.insert(t, string.format("char %d %s", value, value >= visible_lower and value <= visible_upper and ("'" .. char .. "'") or ""))
      end
    end
    local utf8_text = selection
    if not utf8_text then 
      line1, col1 = hv:get_line_byte_position(offset1)
      line2, col2 = hv:get_line_byte_position(offset1 + 3)
      utf8_text = hv.doc:get_text(line1, col1, line2, col2) 
    end
    if utf8_text and (not selection or (#selection > 1 and #selection <= 4)) then
      local codepoint, width = get_utf8_codepoint_and_width(utf8_text, 1)
      if (not selection or width == #selection) and codepoint and width > 1 then
        table.insert(t, style.text)
        table.insert(t, style.font)
        table.insert(t, StatusView.separator2)
        
        table.insert(t, style.text)
        table.insert(t, style.font)
        table.insert(t, string.format("utf8 codepoint U+%s (%d): %s", convert_to_hex(codepoint, 1000000), codepoint, utf8_text))
      end
    end
    return t
  end
})


local function open_hex_view(doc, node)
    node = node or core.root_view:get_active_node_default()
    local view = HexView(doc)
    node:add_view(view)
    core.root_view.root_node:update_layout()
    return view
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
      local codepoint, width = get_utf8_codepoint_and_width(string, i)
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
