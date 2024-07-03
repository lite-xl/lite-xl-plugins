--
-- ProgressBar Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Widget = require "libraries.widget"

---@class widget.progressbar : widget
---@field public percent number
---@field public show_percent boolean
---@field private percent_width number
---@field private percent_x number
---@field private percent_y number
local ProgressBar = Widget:extend()

---Constructor
---@param parent widget
---@param percent number
---@param width number
function ProgressBar:new(parent, percent, width)
  ProgressBar.super.new(self, parent)
  self.type_name = "widget.progressbar"
  self.clickable = false
  self.percent = percent or 0
  self.percent_width = 0
  self.show_percent = true
  self:set_size(width or 200, self:get_font():get_height() + style.padding.y)
end

---@param percent number
function ProgressBar:set_percent(percent)
  self.percent = percent
end

---@return number
function ProgressBar:get_percent()
  return self.percent
end

function ProgressBar:update()
  if not ProgressBar.super.update(self) then return false end

  local font = self:get_font()

  -- update the size
  self:set_label(self.percent .. "%")

  self:set_size(
    nil,
    font:get_height() + style.padding.y
  )

  local percent_width = (self.size.x * (self.percent / 100))

  self:move_towards(self, "percent_width", percent_width, 0.2)

  if self.show_percent then
    self.percent_x = (self:get_width() / 2)
      - (font:get_width(self.label) / 2)

    self.percent_y = style.padding.y / 2
  end

  return true
end

function ProgressBar:draw()
  if not ProgressBar.super.draw(self) then return false end

  renderer.draw_rect(
    self.position.x,
    self.position.y,
    self.percent_width,
    self.size.y,
    style.dim
  )

  if self.show_percent then
    renderer.draw_text(
      self:get_font(),
      self.label,
      self.position.x + self.percent_x,
      self.position.y + self.percent_y,
      style.text
    )
  end

  return true
end


return ProgressBar

