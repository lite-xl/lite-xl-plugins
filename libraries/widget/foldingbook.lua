--
-- FoldingBook Widget.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local style = require "core.style"
local Widget = require "libraries.widget"
local Button = require "libraries.widget.button"

---Represents a foldingbook pane
---@class widget.foldingbook.pane
---@field public name string
---@field public tab widget.button
---@field public container widget
---@field public expanded boolean
local FoldingBookPane = {}

---@class widget.foldingbook : widget
---@field public panes widget.foldingbook.pane[]
local FoldingBook = Widget:extend()

---FoldingBook constructor
---@param parent widget
function FoldingBook:new(parent)
  FoldingBook.super.new(self, parent)
  self.type_name = "widget.foldingbook"
  self.panes = {}
  self.scrollable = true
end

---@param pane widget.foldingbook.pane
function FoldingBook:on_tab_click(pane)
  pane.expanded = not pane.expanded
end

---Adds a new pane to the foldingbook and returns a container widget where
---you can add more child elements.
---@param name string
---@param label string
---@return widget container
function FoldingBook:add_pane(name, label)
  ---@type widget.button
  local tab = Button(self, label)
  tab.border.width = 0
  tab:toggle_expand(true)
  tab:set_icon("+")

  if #self.panes > 0 then
    if self.panes[#self.panes].expanded then
      tab:set_position(0, self.panes[#self.panes].container:get_bottom() + 2)
    else
      tab:set_position(0, self.panes[#self.panes].tab:get_bottom() + 2)
    end
  else
    tab:set_position(0, 10)
  end

  local container = Widget(self)
  container:set_position(0, tab:get_bottom() + 4)
  container:set_size(self:get_width(), 0)

  local pane = {
    name = name,
    tab = tab,
    container = container,
    expanded = false
  }

  tab.on_click = function()
    self:on_tab_click(pane)
  end

  table.insert(self.panes, pane)

  return container
end

---@param name string
---@return widget.foldingbook.pane | nil
function FoldingBook:get_pane(name)
  for _, pane in pairs(self.panes) do
    if pane.name == name then
      return pane
    end
  end
  return nil
end

---Delete a pane and all its childs from the folding book.
---@param name string
---@return boolean deleted
function FoldingBook:delete_pane(name)
  for idx, pane in ipairs(self.panes) do
    if pane.name == name then
      self:remove_child(pane.tab)
      self:remove_child(pane.container)
      table.remove(self.panes, idx)
      return true
    end
  end
  return false
end

---Activates the given pane
---@param name string
---@param visible boolean | nil
function FoldingBook:toggle_pane(name, visible)
  local pane = self:get_pane(name)
  if pane then
    if type(visible) == "boolean" then
      pane.expanded = visible
    else
      pane.expanded = not pane.expanded
    end
  end
end

---Change the tab label of the given pane.
---@param name string
---@param label string
function FoldingBook:set_pane_label(name, label)
  local pane = self:get_pane(name)
  if pane then
    pane.tab:set_label(label)
    return true
  end
  return false
end

---Set or remove the icon for the given pane.
---@param name string
---@param icon string
---@param color? renderer.color|nil
---@param hover_color? renderer.color|nil
function FoldingBook:set_pane_icon(name, icon, color, hover_color)
  local pane = self:get_pane(name)
  if pane then
    pane.tab:set_icon(icon, color, hover_color)
    return true
  end
  return false
end

---Recalculate the position of the elements on resizing or position changes.
function FoldingBook:update()
  if not FoldingBook.super.update(self) then return false end

  ---@type widget.foldingbook.pane
  local prev_pane = nil

  for _, pane in ipairs(self.panes) do
    local tx, ty = 0, 10
    local cx, cy = 0, 0
    local cw, ch = 0, 0

    if prev_pane then
      if prev_pane and prev_pane.container:is_visible() then
        ty = prev_pane.container:get_bottom() + 2
      else
        ty = prev_pane.tab:get_bottom() + 2
      end
    end

    pane.tab:set_position(tx, ty)

    cy = pane.tab:get_bottom() + 4
    cw = self:get_width()
    if #pane.container.childs > 0 then
      ch = pane.container:get_real_height() + 10
    end

    pane.container.border.color = style.divider

    if pane.expanded and not pane.container.hiding then
      pane.container:set_position(cx, cy)
      pane.container:set_size(cw)
      if not pane.container.visible then
        pane.container:set_size(cw, ch)
        pane.container:show_animated(true)
        pane.tab:set_icon("-")
        pane.container.hiding = false
      end
    elseif pane.container.visible and not pane.container.hiding then
      pane.tab:set_icon("+")
      pane.container.hiding = true
      pane.container:hide_animated(true, false, {
        on_complete = function()
          pane.container.hiding = false
        end
      })
    end

    prev_pane = pane
  end

  return true
end

---Here we draw the bottom line on each tab.
function FoldingBook:draw()
  if not FoldingBook.super.draw(self) then return false end

  for _, pane in ipairs(self.panes) do
    local x = pane.tab.position.x
    local y = pane.tab.position.y + pane.tab:get_height()
    local w = self:get_width()
    renderer.draw_rect(x, y, w, 2, style.selection)
  end

  return true
end


return FoldingBook
