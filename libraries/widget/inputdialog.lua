--
-- Input Dialog Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Button = require "libraries.widget.button"
local Dialog = require "libraries.widget.dialog"
local Label = require "libraries.widget.label"
local TextBox = require "libraries.widget.textbox"

---@class widget.inputdialog : widget.dialog
---@field super widget.dialog
---@field message widget.label
---@field text widget.textbox
---@field save widget.button
---@field cancel widget.button
local InputDialog = Dialog:extend()

---Constructor
---@param title string
---@param message string
---@param text string
function InputDialog:new(title, message, text)
  InputDialog.super.new(self, title or "Enter Value")

  self.type_name = "widget.inputdialog"

  self.message = Label(self.panel, message)
  self.text = TextBox(self.panel, text or "")

  local this = self

  self.save = Button(self.panel, "Save")
  self.save:set_icon("S")
  function self.save:on_click()
    this:on_save(this.text:get_text())
    this:on_close()
  end

  self.cancel = Button(self.panel, "Cancel")
  self.cancel:set_icon("C")
  function self.cancel:on_click()
    this:on_close()
  end
end

---Called when the user clicks on save
---@param value string
function InputDialog:on_save(value) end

function InputDialog:update()
  if not InputDialog.super.update(self) then return false end

  self.message:set_position(style.padding.x/2, 0)
  self.text:set_position(style.padding.x/2, self.message:get_bottom() + style.padding.y)

  self.save:set_position(
    style.padding.x/2,
    self.text:get_bottom() + style.padding.y
  )
  self.cancel:set_position(
    self.save:get_right() + style.padding.x,
    self.text:get_bottom() + style.padding.y
  )

  self.panel.size.x = self.panel:get_real_width() + style.padding.x
  self.panel.size.y = self.panel:get_real_height()
  self.size.x = self:get_real_width() - (style.padding.x / 2)
  self.size.y = self:get_real_height() + (style.padding.y / 2)

  self.text:set_size(
    self.size.x - style.padding.x,
    self.text:get_real_height()
  )

  self.close:set_position(
    self.size.x - self.close.size.x - (style.padding.x / 2),
    style.padding.y / 2
  )

  return true
end


return InputDialog

