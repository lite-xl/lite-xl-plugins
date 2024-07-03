--
-- Label Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Widget = require "libraries.widget"

---@class widget.label : widget
local Label = Widget:extend()

---Constructor
---@param parent widget
---@param label string
function Label:new(parent, label)
  Label.super.new(self, parent)
  self.type_name = "widget.label"
  self.clickable = false
  self.border.width = 0
  self.custom_size = {x = 0, y = 0}

  self:set_label(label or "")
end

---@param width? integer
---@param height? integer
function Label:set_size(width, height)
  Label.super.set_size(self, width, height)
  self.custom_size.x = self.size.x
  self.custom_size.y = self.size.y
end

---Set the label text and recalculates the widget size.
---@param text string|widget.styledtext
function Label:set_label(text)
  Label.super.set_label(self, text)

  local font = self:get_font()

  if self.custom_size.x <= 0 then
    if type(text) == "table" then
      self.size.x, self.size.y = self:draw_styled_text(text, 0, 0, true)
    else
      self.size.x = font:get_width(self.label)
      self.size.y = font:get_height()
    end

    if self.border.width > 0 then
      self.size.x = self.size.x + style.padding.x
      self.size.y = self.size.y + style.padding.y
    end
  end
end

function Label:update()
  if not Label.super.update(self) then return false end

  if self.custom_size.x <= 0 then
    -- update the size
    self:set_label(self.label)
  end

  return true
end

function Label:draw()
  if not self:is_visible() then return false end

  self:draw_border()

  local px = self.border.width > 0 and (style.padding.x / 2) or 0
  local py = self.border.width > 0 and (style.padding.y / 2) or 0

  local posx, posy = self.position.x + px, self.position.y + py

  if type(self.label) == "table" then
    self:draw_styled_text(self.label, posx, posy)
  else
    renderer.draw_text(
      self:get_font(),
      self.label,
      posx,
      posy,
      self.foreground_color or style.text
    )
  end

  return true
end


return Label

