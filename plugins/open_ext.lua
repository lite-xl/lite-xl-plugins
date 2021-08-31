-- mod-version:2 -- lite-xl 2.0

-- The general idea is to check if the file opened is valid utf-8
-- since lite-xl only supports UTF8 text, others can be safely assumed
-- to be binary
local core = require "core"
local common = require "core.common"
local style = require "core.style"
local DocView = require "core.docview"
local RootView = require "core.rootview"
local View = require "core.view"


local function validate_utf8(s)
  --[[
    MIT LICENSE
    Copyright (c) 2013 Enrique García Cota
    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
  local p, len = 1, #s
  while p <= len do
    if     p == s:find("[%z\1-\127]", p) then p = p + 1
    elseif p == s:find("[\194-\223][\128-\191]", p) then p = p + 2
    elseif p == s:find(       "\224[\160-\191][\128-\191]", p)
        or p == s:find("[\225-\236][\128-\191][\128-\191]", p)
        or p == s:find(       "\237[\128-\159][\128-\191]", p)
        or p == s:find("[\238-\239][\128-\191][\128-\191]", p) then p = p + 3
    elseif p == s:find(       "\240[\144-\191][\128-\191][\128-\191]", p)
        or p == s:find("[\241-\243][\128-\191][\128-\191][\128-\191]", p)
        or p == s:find(       "\244[\128-\143][\128-\191][\128-\191]", p) then p = p + 4
    else
      return false
    end
  end

  return true
end


local function replace_view(this, that)
  local node = core.root_view.root_node:get_node_for_view(this)
  local idx = node:get_view_idx(this)
  node:remove_view(core.root_view.root_node, this)
  node:add_view(that, idx)
  core.root_view.root_node:update_layout()
  core.redraw = true
end


local function merge(a, ...)
  local r = {}
  for i, v in ipairs(a) do r[i] = v end
  for i, v in ipairs { ... } do r[#r+1] = v end
  return r
end


local msg = "This file is not displayed because it is either binary or uses an unsupported text encoding."
local cmd -- here's evil code again...
if PLATFORM == "Windows" then
  cmd = "start %q"
elseif PLATFORM == "Linux" then
  cmd = "xdg-open %q"
else
  cmd = "open %q"
end

local opt = { "Open anyway", "Open with other program", "Close" }
local opt_actions = {
  function(self)
    -- open anyway
    local view = DocView(core.open_doc(self.filename))
    replace_view(self, view)
  end,
  function(self)
    -- open externally
    local node = core.root_view.root_node:get_node_for_view(self)
    node:close_view(core.root_view.root_node, self)
    system.exec(string.format(cmd, self.filename))
  end,
  function(self)
    local node = core.root_view.root_node:get_node_for_view(self)
    node:close_view(core.root_view.root_node, self)
  end
}


local OpenExtView = View:extend()


function OpenExtView:new(filename)
  OpenExtView.super.new(self)
  self.filename = filename
end


function OpenExtView:get_name()
  return common.basename(self.filename)
end


function OpenExtView:each_option()
  return coroutine.wrap(function()
    local w = (self.size.x - style.padding.x * (#opt + 1)) / #opt
    local h = style.font:get_height() + style.padding.y
    local x, y = self:get_content_offset()
    x = x + style.padding.x
    y = y + self.size.y / 2 + style.padding.y
    for i, o in ipairs(opt) do
      coroutine.yield(i, o, x, y, w, h)
      x = x + w + style.padding.x
    end
  end)
end


function OpenExtView:on_mouse_moved(px, py, dx, dy)
  OpenExtView.super.on_mouse_moved(self, px, py, dx, dy)
  self.hovered = nil
  for i, _, x, y, w, h in self:each_option() do
    if px > x and px <= x + w and py > y and py <= y + h then
      self.hovered = i
      break
    end
  end
end


function OpenExtView:on_mouse_pressed(button, x, y, clicks)
  if OpenExtView.super.on_mouse_pressed(self, button, x, y, clicks) then return end
  if self.hovered then
    opt_actions[self.hovered](self)
  end
end


function OpenExtView:draw()
  self:draw_background(style.background)
  local x, y = self:get_content_offset()
  local lh = style.font:get_height()
  y = y + self.size.y / 2 - style.padding.y - lh
  common.draw_text(style.font, style.text, msg, "center", x, y, self.size.x, lh)
  for i, opt, x, y, w, h in self:each_option() do
    local text_color = i == self.hovered and style.background or style.text
    renderer.draw_rect(x, y, w, h, style.accent)
    if i ~= self.hovered then
      renderer.draw_rect(x + 1, y + 1, w - 2, h - 2, style.background)
    end
    common.draw_text(style.font, text_color, opt, "center", x, y, w, h)
  end
end


local rootview_open_doc = RootView.open_doc
function RootView:open_doc(doc)
  local line = string.sub(doc.lines[1] or "", 1, 128)
  if line == "\n" or line == "" and validate_utf8(line) then
    return rootview_open_doc(self, doc)
  else
    local node = self:get_active_node_default()
    local view = OpenExtView(doc.abs_filename or doc.filename)
    node:add_view(view)
    self.root_node:update_layout()
    return view
  end
end
