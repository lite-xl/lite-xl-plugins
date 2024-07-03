--
-- SelectBox Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local common = require "core.common"
local style = require "core.style"
local Widget = require "libraries.widget"
local ListBox = require "libraries.widget.listbox"

---@class widget.selectbox : widget
---@field private list_container widget
---@field private list widget.listbox
---@field private selected integer
---@field private hover_text renderer.color
local SelectBox = Widget:extend()

---Constructor
---@param parent widget
---@param label string
function SelectBox:new(parent, label)
  SelectBox.super.new(self, parent)
  self.type_name = "widget.selectbox"
  self.size.x = 200 + (style.padding.x * 2)
  self.size.y = self:get_font():get_height() + (style.padding.y * 2)
  self.list_container = Widget()
  self.list_container:set_size(
    self.size.x - self.list_container.border.width,
    150
  )
  self.list = ListBox(self.list_container)
  self.list.border.width = 0
  self.list:enable_expand(true)
  self.selected = 0

  local list_on_row_click = self.list.on_row_click
  self.list.on_row_click = function(this, idx, data)
    list_on_row_click(this, idx, data)
    if idx ~= 1 then
      self.selected = idx-1
      self:on_selected(idx-1, data)
      self:on_change(self.selected)
    end
    self.list_container:hide_animated(true)
  end

  self:set_label(label or "select")
end

---Set the text displayed when no item is selected.
---@param text string
function SelectBox:set_label(text)
  SelectBox.super.set_label(self, "- "..text.." -")
  if not self.list.rows[1] then
    self.list:add_row({"- "..text.." -"})
  else
    self.list.rows[1][1] = "- "..text.." -"
  end
end

---Add selectable option to the selectbox.
---@param text widget.styledtext|string
---@param data any
function SelectBox:add_option(text, data)
  if type(text) == "string" then
    self.list:add_row({ text }, data)
  else
    self.list:add_row(text, data)
  end
end

---Check if a text is longer than the given maximum width and if larger returns
---a chopped version with the overflow_chars appended to it.
---@param text string
---@param max_width number
---@param font widget.font Default is style.font
---@param overflow_chars? string Default is '...'
---@return string chopped_text
---@return boolean overflows True if the text overflows
function SelectBox:text_overflow(text, max_width, font, overflow_chars)
  font = self:get_font(font)
  overflow_chars = overflow_chars or "..."

  local overflow = false
  local overflow_chars_width = font:get_width(overflow_chars)

  if font:get_width(text) > max_width then
    overflow = true
    for i = 1, #text do
      local reduced_text = text:sub(1, #text - i)
      if
        font:get_width(reduced_text) + overflow_chars_width
        <=
        max_width
      then
        text = reduced_text .. "…"
        break
      end
    end
  end

  return text, overflow
end

---Set the active option index.
---@param idx integer
function SelectBox:set_selected(idx)
  if self.list.rows[idx+1] then
    self.selected = idx
    self.list:set_selected(idx+1)
  else
    self.selected = 0
    self.list:set_selected()
  end
  self:on_change(self.selected)
end

---Get the currently selected option index.
---@return integer
function SelectBox:get_selected()
  return self.selected
end

---Get the currently selected option text.
---@return string|nil
function SelectBox:get_selected_text()
  if self.selected > 0 then
    return self.list:get_row_text(self.selected + 1)
  end
  return nil
end

---Get the currently selected option associated data.
---@return any|nil
function SelectBox:get_selected_data()
  if self.selected > 0 then
    return self.list:get_row_data(self.selected + 1)
  end
  return nil
end

---Repositions the listbox container according to the selectbox position
---and available screensize.
function SelectBox:reposition_container()
  local y1 = self.position.y + self:get_height()
  local y2 = self.position.y - self.list:get_height()

  local _, h = system.get_window_size()

  if y1 + self.list:get_height() <= h then
    self.list_container:set_position(
      self.position.x,
      y1
    )
  else
    self.list_container:set_position(
      self.position.x,
      y2
    )
  end

  self.list_container.size.x = self.size.x - (self.border.width * 2)
end

---Overrided to destroy the floating listbox container.
function SelectBox:destroy_childs()
  SelectBox.super.destroy_childs(self)
  self.list_container:destroy()
end

--
-- Events
--

---Overwrite to listen to on_selected events.
---@param item_idx integer
---@param item_data widget.listbox.row
---@diagnostic disable-next-line
function SelectBox:on_selected(item_idx, item_data) end

function SelectBox:on_mouse_enter(...)
  SelectBox.super.on_mouse_enter(self, ...)
  self.hover_text = style.accent
end

function SelectBox:on_mouse_leave(...)
  SelectBox.super.on_mouse_leave(self, ...)
  self.hover_text = nil
end

function SelectBox:on_click(button, x, y)
  SelectBox.super.on_click(self, button, x, y)

  if button == "left" then
    self:reposition_container()

    self.list_container.border.color = style.caret

    self.list_container:toggle_visible(true, true)

    self.list:resize_to_parent()
  end
end

function SelectBox:update()
  if not SelectBox.super.update(self) then return false end

  local font = self:get_font()

  self.size.y = font:get_height() + style.padding.y * 2

  if
    self.list_container.visible
    and
    self.list_container.position.y ~= self.position.y + self:get_height()
  then
    self:reposition_container()
  end

  return true
end

function SelectBox:draw()
  if not SelectBox.super.draw(self) then return false end

  local font = self:get_font()

  local icon_width = style.icon_font:get_width("+")

  local max_width = self.size.x
    - icon_width
    - (style.padding.x * 2) -- left/right paddings
    - (style.padding.x / 2) -- space between icon and text

  local item_text = self.selected == 0 and
    self.label or self.list:get_row_text(self.selected+1)

  local text = self:text_overflow(item_text, max_width, font)

  -- draw label or selected item
  common.draw_text(
    font,
    self.hover_text or self.foreground_color or style.text,
    text,
    "left",
    self.position.x + style.padding.x,
    self.position.y,
    self.size.x - style.padding.x,
    self.size.y
  )

  -- draw arrow down icon
  common.draw_text(
    style.icon_font,
    self.hover_text or self.foreground_color or style.text,
    "-",
    "right",
    self.position.x,
    self.position.y,
    self.size.x - style.padding.x,
    self.size.y
  )

  return true
end


return SelectBox
