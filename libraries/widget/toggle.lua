--
-- Toggle Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Widget = require "libraries.widget"
local Label = require "libraries.widget.label"

-- Hold dimensions of rendered toggle
local BOX = 40
local TOGGLE = 15
local BORDER = 3

---@class widget.toggle : widget
---@field public enabled boolean
---@field private caption_label widget.textbox
---@field private padding integer
---@field private switch_x number
---@field private toggle_bg renderer.color
local Toggle = Widget:extend()

---Constructor
---@param parent widget
---@param label string
---@param enable boolean
function Toggle:new(parent, label, enable)
  Toggle.super.new(self, parent)

  self.type_name = "widget.toggle"

  self.enabled = enable or false
  self.label = label or ""

  self.caption_label = Label(self, self.label)
  self.caption_label:set_position(0, 0)

  self.padding = 2
  self.border.width = 0

  self:set_size(
    self.caption_label:get_width() + (style.padding.x / 2) + (BOX * SCALE),
    self.caption_label:get_height() + ((self.padding * 2) * SCALE)
  )

  self.animate_switch = false
  self.toggle_x = 0
end

---@param enabled boolean
function Toggle:set_toggle(enabled)
  self.enabled = enabled
  self.animate_switch = true
  self:on_change(self.enabled)
end

---@return boolean
function Toggle:is_toggled()
  return self.enabled
end

function Toggle:toggle()
  self.enabled = not self.enabled
  self.animate_switch = true
  self:on_change(self.enabled)
end

---@param text string|widget.styledtext
function Toggle:set_label(text)
  Toggle.super.set_label(self, text)
  self.caption_label:set_label(text)
end

function Toggle:on_click()
  self:toggle()
end

function Toggle:update()
  if not Toggle.super.update(self) then return false end

  local px = style.padding.x / 2

  self:set_size(
    self.caption_label:get_width() + px + (BOX * SCALE),
    self.caption_label:get_height() + ((self.padding * 2) * SCALE)
  )

  self.toggle_x = self.caption_label:get_right() + px

  local switch_x = self.enabled and
    self.position.x + self.toggle_x
      + ((BOX - TOGGLE - BORDER) * SCALE)
    or
    self.position.x + self.toggle_x + (BORDER * SCALE)

  if not self.animate_switch then
    self.switch_x = switch_x
    self.toggle_bg = {}
    local color = self.enabled and style.caret or style.line_number
    for i=1, 4, 1 do self.toggle_bg[i] = color[i] end
  else
    local color = self.enabled and style.caret or style.line_number
    self:move_towards(self, "switch_x", switch_x, 0.2)
    for i=1, 4, 1 do
      self:move_towards(self.toggle_bg, i, color[i], 0.2)
    end
    if self.switch_x == switch_x then
      self.animate_switch = false
    end
  end

  return true
end

function Toggle:draw()
  if not Toggle.super.draw(self) then return false end

  renderer.draw_rect(
    self.position.x + self.toggle_x,
    self.position.y,
    BOX * SCALE,
    self.size.y,
    self.toggle_bg
  )

  renderer.draw_rect(
    self.switch_x,
    self.position.y + (BORDER * SCALE),
    TOGGLE * SCALE,
    self.size.y - ((BORDER * 2) * SCALE),
    style.line_highlight
  )

  return true
end


return Toggle
