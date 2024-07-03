--
-- MessageBox Widget/Dialog.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local core = require "core"
local common = require "core.common"
local style = require "core.style"
local Widget = require "libraries.widget"
local Button = require "libraries.widget.button"
local Label = require "libraries.widget.label"

---@class widget.messagebox : widget
---@field private title widget.label
---@field private icon widget.label
---@field private message widget.label
---@field private buttons widget.button[]
local MessageBox = Widget:extend()

MessageBox.icon_huge_font = style.icon_font:copy(50 * SCALE)

MessageBox.ICON_ERROR = "X"
MessageBox.ICON_INFO = "i"
MessageBox.ICON_WARNING = "!"

---@alias widget.messagebox.icontype
---|>`MessageBox.ICON_ERROR`
---| `MessageBox.ICON_INFO`
---| `MessageBox.ICON_WARNING`

MessageBox.BUTTONS_OK = 1
MessageBox.BUTTONS_OK_CANCEL = 2
MessageBox.BUTTONS_YES_NO = 3
MessageBox.BUTTONS_YES_NO_CANCEL = 4

---@alias widget.messagebox.buttonstype
---|>`MessageBox.BUTTONS_OK`
---| `MessageBox.BUTTONS_OK_CANCEL`
---| `MessageBox.BUTTONS_YES_NO`
---| `MessageBox.BUTTONS_YES_NO_CANCEL`

---@alias widget.messagebox.onclosehandler fun(self: widget.messagebox, button_id: integer, button: widget.button)

---Constructor
---@param parent widget
---@param title string
---@param message string | widget.styledtext
---@param icon widget.messagebox.icontype
---@param icon_color renderer.color
function MessageBox:new(parent, title, message, icon, icon_color)
  MessageBox.super.new(self, parent)
  self.type_name = "widget.messagebox"
  self.draggable = true
  self.scrollable = true
  self.title = Label(self, "")
  self.icon = Label(self, "")
  self.message = Label(self, "")
  self.buttons = {}
  self.last_scale = SCALE

  self:set_title(title or "")
  self:set_message(message or "")
  self:set_icon(icon or "", icon_color)
end

---Change the message box title.
---@param text string | widget.styledtext
function MessageBox:set_title(text)
  self.title:set_label(text)
end

---Change the message box icon.
---@param icon widget.messagebox.icontype
---@param color? renderer.color
function MessageBox:set_icon(icon, color)
  if not color then
    color = style.text
    if icon == MessageBox.ICON_WARNING then
      color = { common.color "#c7763e" }
    elseif icon == MessageBox.ICON_ERROR then
      color = { common.color "#c73e3e" }
    end
  end
  self.icon:set_label({ MessageBox.icon_huge_font, color, icon })
end

---Change the message box message.
---@param text string | widget.styledtext
function MessageBox:set_message(text)
  self.message:set_label(text)
end

---Adds a new button to the message box.
---@param button_or_label string|widget.button
function MessageBox:add_button(button_or_label)
  if type(button_or_label) == "table" then
    table.insert(self.buttons, button_or_label)
  else
    local button = Button(self, button_or_label)
    table.insert(self.buttons, button)
  end

  local button_id = #self.buttons
  local new_button = self.buttons[button_id]
  local on_click = new_button.on_click
  new_button.on_click = function(this, ...)
    on_click(this, ...)
    self:on_close(button_id, new_button)
  end
end

---Calculate the width of all buttons combined.
---@return number width
function MessageBox:get_buttons_width()
  local width = 0
  if #self.buttons > 0 then
    for _, button in ipairs(self.buttons) do
      width = width + button:get_width()
    end
    -- add padding inbetween buttons
    if #self.buttons > 1 then
      width = width + ((style.padding.x) * (#self.buttons - 1))
    end
  end
  return width
end

---Get the height of biggest button.
---@return number height
function MessageBox:get_buttons_height()
  local height = 0
  if #self.buttons > 0 then
    for _, button in ipairs(self.buttons) do
      height = math.max(height, button:get_height())
    end
  end
  return height
end

---Position the buttons relative to the message.
function MessageBox:reposition_buttons()
  local buttons_width = self:get_buttons_width()
  local buttons_x = ((self.size.x / 2) - (buttons_width / 2))
  local buttons_y = self.message:get_bottom() + (style.padding.y * 2)
  if self.icon.label[3] ~= "" then
    buttons_y = math.max(
      buttons_y, self.icon:get_bottom() + (style.padding.y * 2)
    )
  end

  for _, button in ipairs(self.buttons) do
    button:set_position(buttons_x, buttons_y)
    buttons_x = buttons_x + button:get_width() + style.padding.x
  end
end

---Calculate the MessageBox size, centers it relative to screen and shows it.
function MessageBox:show()
  MessageBox.super.show(self)
  self:update()
  self:centered()
end

---Called when the user clicks one of the buttons in the message box.
---@param button_id integer
---@param button widget.button
---@diagnostic disable-next-line
function MessageBox:on_close(button_id, button) self:hide() end

function MessageBox:update()
  if not MessageBox.super.update(self) then return false end

  if self.last_scale ~= SCALE then
    MessageBox.icon_huge_font = style.icon_font:copy(50 * SCALE)
    self.last_scale = SCALE
    self.icon.label[1] = MessageBox.icon_huge_font
  elseif self.updated then
    self.updated = true
    return
  end

  local width = math.max(self.title:get_width())
  width = math.max(width, self.message:get_width() + self.icon:get_width())
  width = math.max(width, self:get_buttons_width())

  local height = self.title:get_height() + style.padding.y
  if self.icon.label[3] == "" then
    height = height + self.message:get_height() + (style.padding.y * 2)
  else
    height = height
      + math.max(self.icon:get_height(), self.message:get_height())
      + (style.padding.y * 2)
  end
  height = height + self:get_buttons_height()

  self:set_size(width + style.padding.x * 2, height + style.padding.y * 2)

  self.title:set_position(
    style.padding.x / 2,
    style.padding.y / 2
  )

  self.icon:set_position(
    style.padding.x,
    self.title:get_bottom() + style.padding.y
  )

  if self.icon.label[3] == "" then
    self.message:set_position(
      style.padding.x,
      self.title:get_bottom() + style.padding.y
    )
  else
    local msg_y = self.title:get_bottom() + style.padding.y + 10
    if self.icon:get_height() > self.message:get_height() then
      msg_y = (self.icon:get_height() / 2)
        - (self.message:get_height() / 2)
        + self.title:get_bottom() + style.padding.y
    end
    self.message:set_position(
      self.icon:get_width() + (style.padding.x * 2) - (style.padding.x / 2),
      msg_y
    )
  end

  self:reposition_buttons()

  return true
end

---We overwrite default draw function to draw the title background.
function MessageBox:draw()
  if not self:is_visible() then return false end

  Widget.super.draw(self)

  self:draw_border()

  if self.background_color then
    self:draw_background(self.background_color)
  else
    self:draw_background(
      self.parent and style.background or style.background2
    )
  end

  if #self.childs > 0 then
    core.push_clip_rect(
      self.position.x,
      self.position.y,
      self.size.x,
      self.size.y
    )
  end

  -- draw the title background
  renderer.draw_rect(
    self.position.x,
    self.position.y,
    self.size.x, self.title:get_height() + style.padding.y,
    style.selection
  )

  for i=#self.childs, 1, -1 do
    self.childs[i]:draw()
  end

  if #self.childs > 0 then
    core.pop_clip_rect()
  end

  self:draw_scrollbar()

  return true
end

---Wrapper to easily show a message box.
---@param title string | widget.styledtext
---@param message string | widget.styledtext
---@param icon widget.messagebox.icontype
---@param icon_color? renderer.color
---@param on_close? widget.messagebox.onclosehandler
---@param buttons? widget.messagebox.buttonstype
function MessageBox.alert(title, message, icon, icon_color, on_close, buttons)
  buttons = buttons or MessageBox.BUTTONS_OK
  ---@type widget.messagebox
  local msgbox = MessageBox(nil, title, message, icon, icon_color)
  if buttons == MessageBox.BUTTONS_OK_CANCEL then
    msgbox:add_button("Ok")
    msgbox:add_button("Cancel")
  elseif buttons == MessageBox.BUTTONS_YES_NO then
    msgbox:add_button("Yes")
    msgbox:add_button("No")
  elseif buttons == MessageBox.BUTTONS_YES_NO_CANCEL then
    msgbox:add_button("Yes")
    msgbox:add_button("No")
    msgbox:add_button("Cancel")
  else
    msgbox:add_button("Ok")
  end

  local msgbox_on_close = msgbox.on_close
  msgbox.on_close = function(self, button_id, button)
    if on_close then
      on_close(self, button_id, button)
    end
    msgbox_on_close(self, button_id, button)
    self:destroy()
  end
  msgbox:show()
end

---Wrapper to easily show a info message box.
---@param title string | widget.styledtext
---@param message string | widget.styledtext
---@param on_close? widget.messagebox.onclosehandler
---@param buttons? widget.messagebox.buttonstype
function MessageBox.info(title, message, on_close, buttons)
  MessageBox.alert(title, message, MessageBox.ICON_INFO, nil, on_close, buttons)
end

---Wrapper to easily show a warning message box.
---@param title string | widget.styledtext
---@param message string | widget.styledtext
---@param on_close? widget.messagebox.onclosehandler
---@param buttons? widget.messagebox.buttonstype
function MessageBox.warning(title, message, on_close, buttons)
  MessageBox.alert(title, message, MessageBox.ICON_WARNING, nil, on_close, buttons)
end

---Wrapper to easily show an error message box.
---@param title string | widget.styledtext
---@param message string | widget.styledtext
---@param on_close? widget.messagebox.onclosehandler
---@param buttons? widget.messagebox.buttonstype
function MessageBox.error(title, message, on_close, buttons)
  MessageBox.alert(title, message, MessageBox.ICON_ERROR, nil, on_close, buttons)
end


return MessageBox
