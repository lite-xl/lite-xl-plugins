--
-- Basic floating example.
--

local core = require "core"
local Widget = require "libraries.widget"
local Button = require "libraries.widget.button"
local CheckBox = require "libraries.widget.checkbox"
local Line = require "libraries.widget.line"
local Label = require "libraries.widget.label"
local TextBox = require "libraries.widget.textbox"

local function on_button_click(self)
  system.show_fatal_error("Clicked:", self.label)
end

---@type widget
local widget = Widget()
widget.size.x = 300
widget.size.y = 300
widget.position.x = 100
widget.draggable = true
widget.scrollable = true

---@type widget.button
local button = Button(widget, "Button1")
button:set_position(10, 10)
button:set_tooltip("Description 1")
button.on_click = on_button_click

---@type widget.button
local button2 = Button(widget, "Button2")
button2:set_position(10, button:get_bottom() + 10)
button2:set_tooltip("Description 2")

---@type widget.button
local button3 = Button(widget, "Button2")
button3:set_position(button:get_right() + 10, 10)
button3:set_tooltip("Description 2")
button3.on_click = on_button_click

---@type widget.button
local button23 = Button(widget, "Button23")
button23:set_position(button:get_right() / 2, 10)
button23:set_tooltip("Description 22")
button23.on_click = on_button_click

---@type widget.checkbox
local checkbox = CheckBox(widget, "Some Checkbox")
checkbox:set_position(10, button2:get_bottom() + 10)
checkbox:set_tooltip("Description checkbox")
checkbox.on_checked = function(_, checked)
  core.log_quiet(tostring(checked))
end

---@type widget.label
local label = Label(widget, "Label:")
label:set_position(10, checkbox:get_bottom() + 10)

---@type widget.textbox
local textbox = TextBox(widget, "", "enter text...")
textbox:set_position(10, label:get_bottom() + 10)
textbox:set_tooltip("Texbox")

---@type widget.button
local button4 = Button(widget, "Button4")
button4:set_position(10, textbox:get_bottom() + 10)
button4:set_tooltip("Description 4")
button4.on_click = on_button_click

local button5 = Button(widget, "Button5")
button5:set_position(10, button4:get_bottom() + 10)
button5:set_tooltip("Description 5")
button5.on_click = on_button_click

local button6 = Button(widget, "Button6")
button6:set_position(10, button5:get_bottom() + 10)
button6:set_tooltip("Description 6")
button6.on_click = on_button_click

---@type widget.line
local line = Line(widget)
line:set_position(0, button6:get_bottom() + 10)

-- reposition items on scale changes
widget.update = function(self)
  if Widget.update(self) then
    button:set_position(10, 10)
    button2:set_position(10, button:get_bottom() + 10)
    button23:set_position(button:get_right() / 2, 10)
    button3:set_position(button:get_right() + 10, 10)
    checkbox:set_position(10, button2:get_bottom() + 10)
    label:set_position(10, checkbox:get_bottom() + 10)
    textbox:set_position(10, label:get_bottom() + 10)
    button4:set_position(10, textbox:get_bottom() + 10)
    button5:set_position(10, button4:get_bottom() + 10)
    button6:set_position(10, button5:get_bottom() + 10)
    line:set_position(0, button6:get_bottom() + 10)
  end
end

widget:show()
