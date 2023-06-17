-- mod-version:3
--[[
  dragdropselected.lua
  provides drag and drop of selected text (in same document)
  - LMB+drag selected text to move it elsewhere
  - or LMB on selection and then LMB at destination (if sticky is enabled)
  - hold ctrl on release to copy selection
  - press escape to abort
  version: 20230616_094245 by SwissalpS
  original: 20200627_133351 by SwissalpS

  TODO: add dragging image
  TODO: use OS drag and drop events
  TODO: change mouse cursor when duplicating (requires change in cpp/SDL2)
--]]
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"
local keymap = require "core.keymap"

config.plugins.dragdropselected = common.merge({
  enabled = true,
  useSticky = false,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Drag n' Drop Selected",
    {
      label = "Enable",
      description = "Activates DnD support within same file. (ctrl to copy)",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Use Sticky Drag",
      description = "Allows to click selection then click insert location.\n"
          .. "No actual dragging needed.",
      path = "useSticky",
      type = "toggle",
      default = false,
    }
  }
}, config.plugins.dragdropselected)


-- helper function to determine if mouse is in selection
-- iLine is line number where mouse is
-- iCol is column where mouse is
-- iLine1 is line number where selection starts
-- iCol1 is column where selection starts
-- iLine2 is line number where selection ends
-- iCol2 is column where selection ends
-- bDuplicating triggers 'exclusive' check making selection area smaller
--   iLine1, iCol1, iLine2, iCol2 can also be packed in a table,
--    in position of iLine1. When this signature is used,
--    iCol1 carries bDuplicating
function DocView:dnd_isInSelection(
    iLine, iCol, iLine1, iCol1, iLine2, iCol2, bDuplicating)

  -- alternate argument signature used?
  if 'table' == type(iLine1) then
    bDuplicating = iCol1
    iLine1, iCol1, iLine2, iCol2 = table.unpack(iLine1)
  end
  -- adjust boundries for duplication actions
  -- this allows users to duplicate selection adjacent to selection
  if bDuplicating then
    iCol1 = iCol1 + 1
    if #self.doc.lines[iLine1] < iCol1 then
      iCol1 = 1
      iLine1 = iLine1 + 1
    end
    iCol2 = iCol2 - 1
    if 0 == iCol2 then
      iLine2 = iLine2 - 1
      iCol2 = #self.doc.lines[iLine2]
    end
  end
  if iLine < iLine1 then return false end
  if iLine > iLine2 then return false end
  if (iLine == iLine1) and (iCol < iCol1) then return false end
  if (iLine == iLine2) and (iCol > iCol2) then return false end
  return true
end -- DocView:dnd_isInSelection


local on_mouse_moved = DocView.on_mouse_moved
function DocView:on_mouse_moved(x, y, ...)
  if not config.plugins.dragdropselected.enabled or not self.dnd_sText then
    -- there is nothing to do -> hand off to original on_mouse_moved()
    return on_mouse_moved(self, x, y, ...)
  end

  -- not sure we need to do this or if we better not
  DocView.super.on_mouse_moved(self, x, y, ...)
  if self.dnd_bDragging then
    -- remove last caret showing insert location
    self.doc:remove_selection(self.doc.last_selection)
  else
    self.dnd_bDragging = true
    -- show that we are dragging something
    self.cursor = 'hand'
    -- make sure selection is marked
    self.doc:set_selection(table.unpack(self.dnd_lSelection))
  end
  -- calculate line and column for current mouse position
  local iLine, iCol = self:resolve_screen_position(x, y)
  -- show insert location (unfortunately it doesn't always show, even when
  -- calling draw_caret)
  self.doc:add_selection(iLine, iCol)
  -- update scroll position, if needed
  self:scroll_to_line(iLine, true)
end -- DocView:on_mouse_moved


local on_mouse_pressed = DocView.on_mouse_pressed
function DocView:on_mouse_pressed(button, x, y, clicks)
  local caught = DocView.super.on_mouse_pressed(self, button, x, y, clicks)
  if caught then
      return caught
  end

  -- no need to proceed if: not enabled, not left button, no selection
  -- or if this is a multi-click event
  if not config.plugins.dragdropselected.enabled
    or 'left' ~= button
    or not self.doc:has_selection()
    or 1 < clicks
  then
      return on_mouse_pressed(self, button, x, y, clicks)
  end

  -- convert pixel coordinates to line and column coordinates
  local iLine, iCol = self:resolve_screen_position(x, y)
  -- get selection coordinates
  local iLine1, iCol1, iLine2, iCol2 = self.doc:get_selection(true)
  if not self:dnd_isInSelection(iLine, iCol, iLine1, iCol1, iLine2, iCol2) then
    -- let 'old' on_mouse_pressed() do whatever it needs to do
    return on_mouse_pressed(self, button, x, y, clicks)
  end

  -- stash selection for inserting later
  self.dnd_sText = self.doc:get_text(self.doc:get_selection())
  self.dnd_lSelection = { iLine1, iCol1, iLine2, iCol2 }
  -- disable blinking caret and stash user setting
  self.dnd_bBlink = config.disable_blink
  config.disable_blink = true
end -- DocView:on_mouse_pressed


-- unset stashes and flag, reset cursor
-- helper for on_mouse_released and
-- when escape is pressed during drag (or not, not worth checking)
local function reset(oDocView)
  if not oDocView then
    oDocView = core.active_view
    if not oDocView:is(DocView) then return end
  end

  config.disable_blink = oDocView.dnd_bBlink
  oDocView.dnd_lSelection = nil
  oDocView.dnd_bDragging = nil
  oDocView.dnd_bBlink = nil
  oDocView.dnd_sText = nil
  oDocView.cursor = 'ibeam'
end -- reset


local on_mouse_released = DocView.on_mouse_released
function DocView:on_mouse_released(button, x, y)
  -- nothing to do if: not enabled or never clicked into selection
  if not config.plugins.dragdropselected.enabled or not self.dnd_sText then
    return on_mouse_released(self, button, x, y)
  end

  local iLine, iCol = self:resolve_screen_position(x, y)
  if not self.dnd_bDragging then
    if not config.plugins.dragdropselected.useSticky then
      -- not using sticky -> clear selection
      self.doc:set_selection(iLine, iCol)
      reset(self)
    end
    return on_mouse_released(self, button, x, y)
  end

  local bDuplicating = keymap.modkeys['ctrl']
  local iLine1, iCol1, iLine2, iCol2 = table.unpack(self.dnd_lSelection)
  if self:dnd_isInSelection(
      iLine, iCol, iLine1, iCol1, iLine2, iCol2, bDuplicating)
  then
    -- drag abborted or initiated drag without holding mouse button (sticky)
    self.doc:set_selection(iLine, iCol)
  else
    -- insert stashed selected text at current position
    if iLine < iLine1 or (iLine == iLine1 and iCol < iCol1) then
      -- delete first
      if not bDuplicating then
        self.doc:set_selection(iLine1, iCol1, iLine2, iCol2)
        self.doc:delete_to(0)
      end
      self.doc:set_selection(iLine, iCol)
      self.doc:text_input(self.dnd_sText)
      -- select inserted text
      if iLine1 == iLine2 then
        self.doc:set_selection(iLine, iCol, iLine, iCol + iCol2 - iCol1)
      else
        self.doc:set_selection(iLine, iCol, iLine + iLine2 - iLine1, iCol2)
      end
    else
      -- insert first
      self.doc:set_selection(iLine, iCol)
      self.doc:text_input(self.dnd_sText)
      if not bDuplicating then
        self.doc:set_selection(iLine1, iCol1, iLine2, iCol2)
        self.doc:delete_to(0)
      end
      -- select inserted text
      if iLine1 == iLine2 then
        if iLine == iLine1 then
          if not bDuplicating then
            iCol = iCol - iCol2 + iCol1
          end
          self.doc:set_selection(iLine, iCol, iLine, iCol + iCol2 - iCol1)
        else
          self.doc:set_selection(iLine, iCol, iLine, iCol + iCol2 - iCol1)
        end
      else
        if not bDuplicating then
          iLine = iLine - iLine2 + iLine1
        end
        self.doc:set_selection(iLine, iCol, iLine + iLine2 - iLine1, iCol2)
      end
    end
  end
  -- unset stashes and flag
  reset(self)
  return on_mouse_released(self, button, x, y)
end -- DocView:on_mouse_released


local draw_caret = DocView.draw_caret
function DocView:draw_caret(x, y)
  if self.dnd_sText and config.plugins.dragdropselected.enabled then
    local iLine, iCol = self:resolve_screen_position(x, y)
    -- don't show carets inside selections
    if self:dnd_isInSelection(iLine, iCol, self.dnd_lSelection, true) then
      return
    end
  end
  draw_caret(self, x, y)
end -- DocView:draw_caret()


-- catch escape-key presses
local on_key_released = keymap.on_key_released
function keymap.on_key_released(k)
  if config.plugins.dragdropselected.enabled and 'escape' == k then
    reset()
  end
  return on_key_released(k)
end

