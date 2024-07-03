--
-- Basic listbox example.
--

local style = require "core.style"
local command = require "core.command"
local Widget = require "libraries.widget"
local ListBox = require "libraries.widget.listbox"

---@type widget
local widget = Widget()
widget.size.x = 400
widget.size.y = 150
widget.position.x = 100
widget.draggable = true
widget.scrollable = false

widget:centered()

---@type widget.listbox
local listbox = ListBox(widget)
listbox.size.y = widget.size.y - widget.border.width*2
listbox:centered()

listbox:add_row({
  style.icon_font, style.syntax.string, "!", style.font, style.text, " Error, ",
  ListBox.COLEND,
  "A message."
})
for i=1, 10000 do
  listbox:add_row({
    tostring(i) .. ". Good ",
    ListBox.COLEND,
    "Hi!."
  })
end
listbox:add_row({
  "More ",
  ListBox.COLEND,
  "Final message."
})

listbox.on_row_click = function(self, idx, data)
  system.show_fatal_error("Clicked a row", idx)
end

widget:show()

command.add(nil,{
  ["listbox-widget:toggle"] = function()
    widget:toggle_visible()
  end
})
