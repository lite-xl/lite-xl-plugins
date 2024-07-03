--
-- Line Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Widget = require "libraries.widget"

---@class widget.line : widget
---@field public padding integer
---@field private custom_width number
local Line = Widget:extend()

---Constructor
---@param parent widget
---@param thickness integer
---@param padding number
function Line:new(parent, thickness, padding)
  Line.super.new(self, parent)
  self.type_name = "widget.line"
  self.size.y = thickness or 2
  self.custom_width = nil
  self.border.width = 0
  self.padding = padding or (style.padding.x / 2)
end

---Set the thickness of the line
---@param thickness number
function Line:set_thickness(thickness)
  self.size.y  = thickness or 2
end

---Set a custom width for the line
---@param width number
function Line:set_width(width)
  self.custom_width = width
  self.size.x = width
end

function Line:draw()
  if not self:is_visible() then return false end

  if not self.custom_width then
    self.size.x = self.parent.size.x - (self.padding * 2)
  end

  renderer.draw_rect(
    self.position.x + self.padding,
    self.position.y,
    self.size.x,
    self.size.y,
    self.foreground_color or style.caret
  )

  return true
end


return Line

