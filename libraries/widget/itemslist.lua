--
-- ItemsList Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--
local style = require "core.style"
local Widget = require "libraries.widget"
local Button = require "libraries.widget.button"
local ListBox = require "libraries.widget.listbox"
local InputDialog = require "libraries.widget.inputdialog"
local MessageBox = require "libraries.widget.messagebox"

---@class widget.itemslist : widget
---@field list widget.listbox
---@field add widget.button
---@field remove widget.button
local ItemsList = Widget:extend()

---Constructor
---@param parent widget
function ItemsList:new(parent)
  ItemsList.super.new(self, parent)

  self.type_name = "widget.itemslist"

  self.border.width = 0

  self.dialog = false

  self.list = ListBox(self)

  local this = self

  function self.list:on_mouse_pressed(button, x, y, clicks)
    if not ListBox.on_mouse_pressed(self, button, x, y, clicks) then
      return false
    end

    if clicks == 2 and not this.dialog then
      this.dialog = true
      local selected = this.list:get_selected()
      local selvalue = this.list:get_row_text(selected)
      ---@type widget.inputdialog
      local input = InputDialog("Edit Item", "Enter the new item value:", selvalue)
      function input:on_save(value)
        this:edit_item(selected, value)
      end
      function input:on_close()
        InputDialog.on_close(self)
        self:destroy()
        this.dialog = false
      end
      input:show()
    end

    return true
  end

  self.add = Button(self, "Add")
  self.add:set_icon("B")
  function self.add:on_click()
    if not this.dialog then
      ---@type widget.inputdialog
      local input = InputDialog("Add Item", "Enter the new item:")
      function input:on_save(value)
        this:add_item(value)
      end
      function input:on_close()
        InputDialog.on_close(self)
        self:destroy()
        this.dialog = false
      end
      input:show()
    end
  end

  self.remove = Button(self, "Remove")
  self.remove:set_icon("C")
  function self.remove:on_click()
    local selected = this.list:get_selected()
    if selected then
      this:remove_item(selected)
    else
      MessageBox.error("No item selected", "Please select an item to remove")
    end
  end
end

---Add a new item into the list.
---@param text widget.styledtext | string
---@param data any
function ItemsList:add_item(text, data)
  if type(text) == "string" then
    text = {text}
  end
  self.list:add_row(text, data)
  self.list:set_visible_rows()
  self:on_change()
end

---Edit an existing item on the list.
---@param idx integer
---@param text widget.styledtext | string
---@param data any
function ItemsList:edit_item(idx, text, data)
  if type(text) == "string" then
    text = {text}
  end
  self.list:set_row(idx, text)
  if data then
    self.list:set_row_data(idx, data)
  end
  self:on_change()
end

---Remove the given item from the list.
---@param idx integer
function ItemsList:remove_item(idx)
  self.list:remove_row(idx)
  self:on_change()
end

---Return the items from the list.
---@return table<integer, string>
function ItemsList:get_items()
  local output = {}
  local count = #self.list.rows
  for i=1, count, 1 do
    table.insert(output, self.list:get_row_text(i))
  end
  return output
end

function ItemsList:update()
  if not ItemsList.super.update(self) then return false end

  if self.size.x == 0 then
    self.size.x = self.add:get_width()
      + (style.padding.x / 2) + self.remove:get_width() + (50 * SCALE)
    self.size.y = self.add:get_height() + (style.padding.y * 2) + 100
  end

  self.list:set_position(0, 0)

  self.list:set_size(
    self.size.x,
    self.size.y - self.add:get_height() - (style.padding.y * 2)
  )

  self.add:set_position(0, self.list:get_bottom() + style.padding.y)

  self.remove:set_position(
    self.add:get_right() + (style.padding.x / 2),
    self.list:get_bottom() + style.padding.y
  )

  return true
end


return ItemsList
