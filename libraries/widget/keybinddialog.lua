--
-- KeyBinding Dialog Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local keymap = require "core.keymap"
local style = require "core.style"
local Button = require "libraries.widget.button"
local Dialog = require "libraries.widget.dialog"
local Label = require "libraries.widget.label"
local Line = require "libraries.widget.line"
local ListBox = require "libraries.widget.listbox"
local MessageBox = require "libraries.widget.messagebox"

---@type widget.keybinddialog
local current_dialog = nil

---@class widget.keybinddialog : widget.dialog
---@field super widget.dialog
---@field selected integer
---@field shortcuts widget.listbox
---@field add widget.button
---@field remove widget.button
---@field line widget.line
---@field message widget.label
---@field binding widget.label
---@field mouse_intercept widget.label
---@field save widget.button
---@field reset widget.button
---@field cancel widget.button
local KeybindDialog = Dialog:extend()

---Constructor
function KeybindDialog:new()
  KeybindDialog.super.new(self, "Keybinding Selector")

  self.type_name = "widget.keybinddialog"

  self.selected = nil

  local this = self

  self.shortcuts = ListBox(self.panel)
  self.shortcuts:set_size(100, 100)
  function self.shortcuts:on_row_click(idx, data)
    this.selected = idx
  end

  self.add = Button(self.panel, "Add")
  self.add:set_icon("B")
  function self.add:on_click()
    this.shortcuts:add_row({"none"})
    this.shortcuts:set_selected(#this.shortcuts.rows)
    this.shortcuts:set_visible_rows()
    this.selected = #this.shortcuts.rows
  end

  self.remove = Button(self.panel, "Remove")
  self.remove:set_icon("C")
  function self.remove:on_click()
    local selected = this.shortcuts:get_selected()
    if selected then
      this.shortcuts:remove_row(selected)
      this.shortcuts:set_selected(nil)
      this.selected = nil
    else
      MessageBox.error("No shortcut selected", "Please select an shortcut to remove")
    end
  end

  self.line = Line(self.panel)

  self.message = Label(self.panel, "Press a key combination to change selected")

  self.mouse_intercept = Label(self.panel, "Grab mouse events here")
  self.mouse_intercept.border.width = 1
  self.mouse_intercept.clickable = true
  self.mouse_intercept:set_size(100, 100)
  function self.mouse_intercept:on_mouse_pressed(button, x, y, clicks)
    keymap.on_mouse_pressed(button, x, y, clicks)
    return true
  end
  function self.mouse_intercept:on_mouse_wheel(y)
    keymap.on_mouse_wheel(y)
    return true
  end
  function self.mouse_intercept:on_mouse_enter(...)
    Label.super.on_mouse_enter(self, ...)
    self.border.color = style.caret
  end
  function self.mouse_intercept:on_mouse_leave(...)
    Label.super.on_mouse_leave(self, ...)
    self.border.color = style.text
  end

  self.save = Button(self.panel, "Save")
  self.save:set_icon("S")
  function self.save:on_click()
    this:on_save(this:get_bindings())
    this:on_close()
  end

  self.reset = Button(self.panel, "Reset")
  function self.reset:on_click()
    this:on_reset()
    this:on_close()
  end

  self.cancel = Button(self.panel, "Cancel")
  self.cancel:set_icon("C")
  function self.cancel:on_click()
    this:on_close()
  end
end

---@param bindings table<integer, string>
function KeybindDialog:set_bindings(bindings)
  self.shortcuts:clear()
  for _, binding in ipairs(bindings) do
    self.shortcuts:add_row({binding})
  end
  if #bindings > 0 then
    self.shortcuts:set_selected(1)
    self.selected = 1
  end
  self.shortcuts:set_visible_rows()
end

---@return table<integer, string>
function KeybindDialog:get_bindings()
  local bindings = {}
  for idx=1, #self.shortcuts.rows, 1 do
    table.insert(bindings, self.shortcuts:get_row_text(idx))
  end
  return bindings
end

---Show the dialog and enable key interceptions
function KeybindDialog:show()
  current_dialog = self
  KeybindDialog.super.show(self)
end

---Hide the dialog and disable key interceptions
function KeybindDialog:hide()
  current_dialog = nil
  KeybindDialog.super.hide(self)
end

---Called when the user clicks on save
---@param bindings string
function KeybindDialog:on_save(bindings) end

---Called when the user clicks on reset
function KeybindDialog:on_reset() end

function KeybindDialog:update()
  if not KeybindDialog.super.update(self) then return false end

  self.shortcuts:set_position(style.padding.x/2, 0)

  self.add:set_position(
    style.padding.x/2,
    self.shortcuts:get_bottom() + style.padding.y
  )

  self.remove:set_position(
    self.add:get_right() + (style.padding.x/2),
    self.shortcuts:get_bottom() + style.padding.y
  )

  self.line:set_position(
    0,
    self.remove:get_bottom() + style.padding.y
  )

  self.message:set_position(
    style.padding.x/2,
    self.line:get_bottom() + style.padding.y
  )
  self.mouse_intercept:set_position(
    style.padding.x/2,
    self.message:get_bottom() + style.padding.y
  )

  self.save:set_position(
    style.padding.x/2,
    self.mouse_intercept:get_bottom() + style.padding.y
  )
  self.reset:set_position(
    self.save:get_right() + style.padding.x,
    self.mouse_intercept:get_bottom() + style.padding.y
  )
  self.cancel:set_position(
    self.reset:get_right() + style.padding.x,
    self.mouse_intercept:get_bottom() + style.padding.y
  )

  self.panel.size.x = self.panel:get_real_width() + style.padding.x
  self.panel.size.y = self.panel:get_real_height()
  self.size.x = self:get_real_width() - (style.padding.x / 2)
  self.size.y = self:get_real_height() + (style.padding.y / 2)

  self.shortcuts:set_size(self.size.x - style.padding.x)

  self.line:set_width(self.size.x - style.padding.x)

  self.mouse_intercept:set_size(self.size.x - style.padding.x)

  return true
end

--------------------------------------------------------------------------------
-- Intercept keymap events
--------------------------------------------------------------------------------

-- Same declarations as in core.keymap because modkey_map is not public
local macos = PLATFORM == "Mac OS X"
local modkeys_os = require("core.modkeys-" .. (macos and "macos" or "generic"))
local modkey_map = modkeys_os.map
local modkeys = modkeys_os.keys

---Copied from core.keymap because it is not public
local function key_to_stroke(k)
  local stroke = ""
  for _, mk in ipairs(modkeys) do
    if keymap.modkeys[mk] then
      stroke = stroke .. mk .. "+"
    end
  end
  return stroke .. k
end

local keymap_on_key_pressed = keymap.on_key_pressed
function keymap.on_key_pressed(k, ...)
  if current_dialog and current_dialog.selected then
    local mk = modkey_map[k]
    if mk then
      keymap.modkeys[mk] = true
      -- work-around for windows where `altgr` is treated as `ctrl+alt`
      if mk == "altgr" then
        keymap.modkeys["ctrl"] = false
      end
      current_dialog.shortcuts:set_row(current_dialog.selected, {key_to_stroke("")})
    else
      current_dialog.shortcuts:set_row(current_dialog.selected, {key_to_stroke(k)})
    end
    return true
  else
    return keymap_on_key_pressed(k, ...)
  end
end


return KeybindDialog

