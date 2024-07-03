--
-- NoteBook Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Widget = require "libraries.widget"
local Button = require "libraries.widget.button"

local HSPACING = 2
local VSPACING = 2

---Represents a notebook pane
---@class widget.notebook.pane
---@field public name string
---@field public tab widget.button
---@field public container widget
local NoteBookPane = {}

---@class widget.notebook : widget
---@field public panes widget.notebook.pane[]
---@field public active_pane widget.notebook.pane
local NoteBook = Widget:extend()

---Notebook constructor
---@param parent widget
function NoteBook:new(parent)
  NoteBook.super.new(self, parent)
  self.type_name = "widget.notebook"
  self.panes = {}
  self.active_pane = nil
end

---Called when a tab is clicked.
---@param pane widget.notebook.pane
---@diagnostic disable-next-line
function NoteBook:on_tab_click(pane) end

---Adds a new pane to the notebook and returns a container widget where
---you can add more child elements.
---@param name string
---@param label string
---@return widget container
function NoteBook:add_pane(name, label)
  ---@type widget.button
  local tab = Button(self, label)
  tab.border.width = 0

  if #self.panes > 0 then
    tab:set_position(self.panes[#self.panes].tab:get_right() + HSPACING, 0)
  end

  local container = Widget(self)
  container.scrollable = true
  container:set_position(0, tab:get_bottom() + VSPACING)
  container:set_size(
    self:get_width(),
    self:get_height() - tab:get_height() - VSPACING
  )

  local pane = {
    name = name,
    tab = tab,
    container = container
  }

  if not self.active_pane then
    self.active_pane = pane
  end

  tab.on_click = function()
    self.active_pane = pane
    self:on_tab_click(pane)
  end

  table.insert(self.panes, pane)

  return container
end

---Search the pane for the given name and return it.
---@param name string
---@return widget.notebook.pane | nil
function NoteBook:get_pane(name)
  for _, pane in pairs(self.panes) do
    if pane.name == name then
      return pane
    end
  end
  return nil
end

---Activates the given pane.
---@param name string
---@return boolean
function NoteBook:set_pane(name)
  local pane = self:get_pane(name)
  if pane then
    self.active_pane = pane
    return true
  end
  return false
end

---Change the tab label of the given pane.
---@param name string
---@param label string
function NoteBook:set_pane_label(name, label)
  local pane = self:get_pane(name)
  if pane then
    pane.tab:set_label(label)
    return true
  end
  return false
end

---Set or remove the icon for the given pane.
---@param name string
---@param icon? string|nil
---@param color? renderer.color|nil
---@param hover_color? renderer.color|nil
function NoteBook:set_pane_icon(name, icon, color, hover_color)
  local pane = self:get_pane(name)
  if pane then
    pane.tab:set_icon(icon, color, hover_color)
    return true
  end
  return false
end

---Recalculate the position of the elements on resizing or position
---changes and also make changes to properly render active pane.
function NoteBook:update()
  if not NoteBook.super.update(self) then return false end

  for pos, pane in pairs(self.panes) do
    if pos ~= 1 then
      pane.tab:set_position(
        self.panes[pos-1].tab:get_right() + HSPACING, 0
      )
    else
      pane.tab:set_position(0, 0)
    end
    if pane ~= self.active_pane then
      if pane.container.visible then
        pane.tab.background_color = style.background
        pane.tab.foreground_color = style.text
        pane.container:hide()
      end
    elseif not pane.container.visible then
      pane.container:show()
    end
  end

  if self.active_pane then
    self.active_pane.tab.foreground_color = style.accent

    self.active_pane.container:set_position(
      0, self.active_pane.tab:get_bottom() + VSPACING
    )
    self.active_pane.container:set_size(
      self:get_width(),
      self:get_height() - self.active_pane.tab:get_height() - VSPACING
    )
    self.active_pane.container.border.color = style.divider
  end

  return true
end

---Here we draw the bottom line on the tab of active pane.
function NoteBook:draw()
  if not NoteBook.super.draw(self) then return false end

  if self.active_pane then
    local x = self.active_pane.tab.position.x
    local y = self.active_pane.tab.position.y + self.active_pane.tab:get_bottom()
    local w = self.active_pane.tab:get_width()
    renderer.draw_rect(x, y, w, HSPACING, style.caret)
  end

  return true
end


return NoteBook
