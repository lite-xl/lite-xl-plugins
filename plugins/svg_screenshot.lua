-- mod-version:3

--[[
 base64 -- v1.5.3 public domain Lua base64 encoder/decoder
 no warranty implied; use at your own risk
 Needs bit32.extract function. If not present it's implemented using BitOp
 or Lua 5.3 native bit operators. For Lua 5.1 fallbacks to pure Lua
 implementation inspired by Rici Lake's post:
   http://ricilake.blogspot.co.uk/2007/10/iterating-bits-in-lua.html
 author: Ilya Kolbin (iskolbin@gmail.com)
 url: github.com/iskolbin/lbase64
 COMPATIBILITY
 Lua 5.1+, LuaJIT
 LICENSE
 See end of file for license information.
--]]

-- This utility has been altered to remove unused functionality

--[[
------------------------------------------------------------------------------
License for the base64 utility
------------------------------------------------------------------------------
MIT License
Copyright (c) 2018 Ilya Kolbin
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
--]]

local base64 = {}

local extract = function( v, from, width )
  return ( v >> from ) & ((1 << width) - 1)
end


function base64.makeencoder( s62, s63, spad )
  local encoder = {}
  for b64code, char in pairs{[0]='A','B','C','D','E','F','G','H','I','J',
    'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
    'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
    'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
    '3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='} do
    encoder[b64code] = char:byte()
  end
  return encoder
end

local DEFAULT_ENCODER = base64.makeencoder()

local char, concat = string.char, table.concat

function base64.encode( str, encoder, usecaching )
  encoder = encoder or DEFAULT_ENCODER
  local t, k, n = {}, 1, #str
  local lastn = n % 3
  local cache = {}
  for i = 1, n-lastn, 3 do
    local a, b, c = str:byte( i, i+2 )
    local v = a*0x10000 + b*0x100 + c
    local s
    if usecaching then
      s = cache[v]
      if not s then
        s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
        cache[v] = s
      end
    else
      s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
    end
    t[k] = s
    k = k + 1
  end
  if lastn == 2 then
    local a, b = str:byte( n-1, n )
    local v = a*0x10000 + b*0x100
    t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
  elseif lastn == 1 then
    local v = str:byte( n )*0x10000
    t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
  end
  return concat( t )
end

--------------------------------------------------------------------------------

local core = require "core"
local common = require "core.common"
local keymap = require "core.keymap"
local command = require "core.command"
local style = require "core.style"

-- TODO: what about the vertical location of text? (svg uses the baseline)
-- TODO: add the overrides only when screenshotting to avoid overhead
-- TODO: complete the font table

local start_screenshot = false
local screenshotting = false
local draw_data = {}
local known_fonts = {}
local known_colors = {}
local current_clip = ""
local known_clips = {}

local function is_color(t)
  if type(t) ~= "table" then return false end
  if #t ~=4 then return false end
  for i=1,4 do
    if type(t[i]) ~= "number" then return false end
  end
  return true
end

local function get_color(color)
  return "rgba(" .. table.concat(color, ",") .. ")"
end

local function get_fill_color(color)
  if known_colors[color] then
    return "var(--lxl_".. known_colors[color] .. ")"
  end

  local fill_color = get_color(color)
  -- Try to find a known color with the same values
  for k, v in pairs(known_colors) do
    if get_color(k) == fill_color then
      -- Save the color with the name of the found color
      known_colors[color] = v
      return get_fill_color(k)
    end
  end
  -- Try to find the color with a different opacity
  local opaque_color = {table.unpack(color)}
  opaque_color[4] = 255
  local opaque_fill_color = get_color(opaque_color)
  for k, _ in pairs(known_colors) do
    if get_color(k) == opaque_fill_color then
      -- Hacky way to reuse the defined color with a custom opacity
      return get_fill_color(k) .. '" opacity="' .. color[4]/255
    end
  end
  -- Logging warning next frame to avoid drawing it in the screenshot
  core.add_thread(function()
    core.warn("Unknown color: %s", common.serialize(color))
  end)
  return fill_color
end

local old_begin_frame = renderer.begin_frame
function renderer.begin_frame(...)
  if start_screenshot then
    start_screenshot = false
    screenshotting = true
    known_fonts = {}
    current_clip = ""
    known_clips = {}
    -- `shape-rendering="crispEdges"` is needed to avoid antialisaing issues like
    -- spaces between rects
    -- `font-variant-ligatures: none;` is needed because we don't support ligatures,
    -- so the svg shouldn't too
    table.insert(draw_data, string.format([[
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="%d" height="%d" viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg" version="1.1" shape-rendering="crispEdges">
<style>
  * {
    font-variant-ligatures: none;
  }
</style>]], core.root_view.size.x, core.root_view.size.y, core.root_view.size.x, core.root_view.size.y))
    -- Extract known colors
    known_colors = {}
    local colors = {}
    for k, v in pairs(style) do
      if is_color(v) then
        known_colors[v] = k
        table.insert(colors, string.format([[
--lxl_%s: %s;
]], k, get_color(v)))
      end
    end
    for k, v in pairs(style.syntax) do
      if is_color(v) then
        known_colors[v] = k
        table.insert(colors, string.format([[
--lxl_%s: %s;
]], k, get_color(v)))
      end
    end
    table.insert(draw_data, "<style>\n:root{" .. table.concat(colors) .. "}</style>")
    -- Needed because we close it when we first set a clip
    table.insert(draw_data, "<g>")
  end
  return old_begin_frame(...)
end

local old_end_frame = renderer.end_frame
function renderer.end_frame(...)
  local res = old_end_frame(...)
  if screenshotting then
    screenshotting = false
    -- Needed to close the last clip
    table.insert(draw_data, "</g>")
    table.insert(draw_data, string.format("</svg>"))
    core.command_view:enter("Choose a name", {
      validate = function(text) return #text > 0 end,
      submit = function(name)
        -- Add extension if needed
        name = string.gsub(name, "%.[sS][vV][gG]", "") .. ".svg"
        local fp = assert( io.open(name, "wb") )
        fp:write(table.concat(draw_data, "\n"))
        fp:close()
      end
    })
  end
  return res
end

-- Used by our renderer to round coordinates
local function rect_to_grid(x, y, w, h)
  local x1, y1, x2, y2 = math.floor(x + .5), math.floor(y + .5),
                        math.floor(x + w + .5), math.floor(y + h + .5)
  return x1, y1, x2 - x1, y2 - y1
end

local old_draw_rect = renderer.draw_rect
function renderer.draw_rect(x, y, width, height, color, ...)
  if screenshotting then
    local _x, _y, _w, _h = rect_to_grid(x, y, width, height)
    local fill_color = get_fill_color(color)
    table.insert(draw_data,
                string.format([[<rect x="%d" y="%d" width="%d" height="%d" fill="%s" />]],
                             _x, _y, _w, _h, fill_color))
  end
  return old_draw_rect(x, y, width, height, color, ...)
end

local function get_font_style(font)
  local path = font:get_path()
  -- Only consider the first font in a fontgroup
  if type(path) == "table" then path = path[1] end
  local fp = assert( io.open(path, "rb") )
  local font_content = fp:read("a")
  fp:close()
  local name, extension = string.match(common.basename(path), "(.*)%.(.-)$")
  local encoded_font = base64.encode(font_content)
  -- TODO: We need a table of extensions -> mime-type
  --       For now we just assume TrueType
  return name, string.format([[
<style>
  @font-face{
      font-family:"%s";
      src:url(data:application/font-%s;charset=utf-8;base64,%s) format("%s");
      font-weight:normal;font-style:normal;
  }
</style>]], name, extension, encoded_font, "truetype")
end

local old_draw_text = renderer.draw_text
function renderer.draw_text(font, text, x, y, color, ...)
  if screenshotting then
    local font_path = font:get_path()
  -- Only consider the first font in a fontgroup
    if type(font_path) == "table" then font_path = font_path[1] end
    if not known_fonts[font_path] then
      local name, encoded_font = get_font_style(font)
      known_fonts[font_path] = name
      -- FIXME: We might want to keep all of those and add them all at the start,
      --        before concatenating the draw_data
      table.insert(draw_data, encoded_font)
    end
    local fill_color = get_fill_color(color)
    -- Split at spaces, because multiple spaces get removed by svg renderers
    for s, e in string.gmatch(text, "()%S+()") do
      local partial_text = string.sub(text, s, e - 1)
      partial_text = partial_text:gsub("%]%]>", "]]]]><![CDATA[>") -- escape eventual CDATA end token in the text
      partial_text = partial_text:gsub("%]", "]]>]<![CDATA[") -- escape `]` because WebKit ends the CDATA with it <.<
      local offset = font:get_width(string.sub(text, 1, s - 1))
      table.insert(draw_data, string.format([=[
<text x="%.2f" y="%d" font-family="%s" font-size="%.2fpx" fill="%s">
  <![CDATA[%s]]>
</text>]=], x + offset, math.floor(y + font:get_height() * 0.8), known_fonts[font_path],
            math.floor(font:get_size()), fill_color, partial_text))
    end
  end
  return old_draw_text(font, text, x, y, color, ...)
end

local old_set_clip_rect = renderer.set_clip_rect
function renderer.set_clip_rect(x, y, width, height, ...)
  if screenshotting then
    local _x, _y, _w, _h = rect_to_grid(x, y, width, height)
    current_clip = string.format("%d_%d_%d_%d", _x, _y, _w, _h)
    -- Close last clip
    table.insert(draw_data, "</g>")
    -- Ideally we don't need this, but just use the `<g clip-path="path(...`
    -- that is commented below, but it looks like each browser handles it
    -- differently:
    -- * Chromium considers the path as relative for some reason, and doesn't
    --   seem to support `view-box` correctly.
    -- * Epiphany (WebKit) has the same relative issue, but at least works with
    --   `view-box`.
    -- * Firefox seems to handle it correctly.
    --
    -- So for now let's just use the clipPaths with their id...
    if not known_clips[current_clip] then
      known_clips[current_clip] = true
      table.insert(draw_data, string.format([[
<clipPath id="clip-%s">
  <rect x="%d" y="%d" width="%d" height="%d" />
</clipPath>]], current_clip, _x, _y, _w, _h))
    end

--     table.insert(draw_data, string.format([[
-- <g clip-path="path('M%d %d h%d v%d h%d Z') view-box">
-- ]], _x, _y, _w, _h, -_w))

    table.insert(draw_data, string.format([[
<g clip-path="url(#clip-%s)">
]], current_clip))
  end
  return old_set_clip_rect(x, y, width, height, ...)
end

command.add(nil, {
  ["screenshot:svg-screenshot"] = function()
    start_screenshot = true
  end
})

keymap.add({
  ["ctrl+f12"] = "screenshot:svg-screenshot"
})
