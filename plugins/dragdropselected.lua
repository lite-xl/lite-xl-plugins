-- mod-version:3
--[[
  dragdropselected.lua
  provides drag and drop of selected text (in same document)
  - LMB+drag selected text to move it elsewhere
  - or LMB on selection and then LMB at destination (if sticky is enabled)
  - hold ctrl on release to copy selection
  - press escape to abort
  - supports multiple selections
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

local dnd = {}

config.plugins.dragdropselected = common.merge({
  enabled = true,
  useSticky = false,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Drag n' Drop Selected",
    {
      label = "Enabled",
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
function dnd.isInSelection(iLine, iCol, iLine1, iCol1, iLine2, iCol2)
  if iLine < iLine1 then return false end
  if iLine > iLine2 then return false end
  if (iLine == iLine1) and (iCol < iCol1) then return false end
  if (iLine == iLine2) and (iCol > iCol2) then return false end
  return true
end -- dnd.isInSelection


function DocView:dnd_collectSelections()
  self.dnd_lSelections = {}
  for _, iLine1, iCol1, iLine2, iCol2, bSwap in self.doc:get_selections(true) do
    -- skip empty selections (jic Doc didn't skip them)
    if iLine1 ~= iLine2 or iCol1 ~= iCol2 then
      self.dnd_lSelections[#self.dnd_lSelections + 1] =
          { iLine1, iCol1, iLine2, iCol2, bSwap }

    end
  end
  if 0 == #self.dnd_lSelections then
    self.dnd_lSelections = nil
  end
  return self.dnd_lSelections
end -- DocView:dnd_collectSelections


function dnd.getSelectedText(doc)
  local iPrevious = 0
  local sOut, sPart
  for _, iLine1, iCol1, iLine2, iCol2 in doc:get_selections(true) do
    -- skip empty markers
    if iLine1 ~= iLine2 or iCol1 ~= iCol2 then
      sPart = doc:get_text(iLine1, iCol1, iLine2, iCol2)
      -- double check that part is not empty
      if '' ~= sPart then
        if 0 == iPrevious then
          sOut = sPart
        else
          sOut = sOut .. (iPrevious == iLine1 and ' ' or '\n') .. sPart
        end
        iPrevious = iLine2
      end -- not empty
    end -- not empty
  end -- loop selections
  return sOut
end -- dnd.getSelectedText


-- checks whether given coordinates are in a selection
-- iLine, iCol are position of mouse
-- bDuplicating triggers 'exclusive' check making checked area smaller
function DocView:dnd_isInSelections(iLine, iCol, bDuplicating)
  self.dnd_lSelections = self.dnd_lSelections or self:dnd_collectSelections()
  if not self.dnd_lSelections then return nil end

  local iLine1, iCol1, iLine2, iCol2, bSwap
  local i = #self.dnd_lSelections
  repeat
    iLine1, iCol1, iLine2, iCol2, bSwap = table.unpack(self.dnd_lSelections[i])
    if bDuplicating then
      -- adjust boundries for duplication actions
      -- this allows users to duplicate selection adjacent to selection
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
    end -- if duplicating

    if dnd.isInSelection(iLine, iCol, iLine1, iCol1, iLine2, iCol2) then
      return self.dnd_lSelections
    end

    i = i - 1
  until 0 == i
  return nil
end -- DocView:dnd_isInSelections


-- restore selections that existed when DnD was initiated
function DocView:dnd_setSelections()
  if not self.dnd_lSelections or 0 == #self.dnd_lSelections then
    return
  end

  local iTotal = #self.dnd_lSelections
  local i = iTotal
  repeat
    if i == iTotal then
      self.doc:set_selection(table.unpack(self.dnd_lSelections[i]))
    else
      self.doc:add_selection(table.unpack(self.dnd_lSelections[i]))
    end
    i = i - 1
  until 0 == i
end -- DocView:dnd_setSelections


-- unset stashes and flag, reset cursor
-- helper for on_mouse_released and
-- when escape is pressed during drag (or not, not worth checking)
function dnd.reset(oDocView)
  if not oDocView then
    oDocView = core.active_view
    if not oDocView:is(DocView) then return end
  end

  if nil ~= oDocView.dnd_bBlink then
    config.disable_blink = oDocView.dnd_bBlink
  end
  oDocView.dnd_lSelections = nil
  oDocView.dnd_bDragging = nil
  oDocView.dnd_bBlink = nil
  oDocView.cursor = 'ibeam'
  oDocView.dnd_sText = nil
end -- dnd.reset


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
    -- make sure selections are marked
    self:dnd_setSelections()
  end
  -- calculate line and column for current mouse position
  local iLine, iCol = self:resolve_screen_position(x, y)
  -- show insert location
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

  -- sticky mode support
  if self.dnd_bDragging then
    return true
  end

  -- no need to proceed if: not enabled, not left button, no selection
  -- or if this is a multi-click event
  -- NOTE: can't use self.doc:has_selection(), that only looks at last one
  if not config.plugins.dragdropselected.enabled
    or 'left' ~= button
    or 1 < clicks
    or not self:dnd_isInSelections(self:resolve_screen_position(x, y))
  then
    dnd.reset(self)
    -- let 'old' on_mouse_pressed() do whatever it needs to do
    return on_mouse_pressed(self, button, x, y, clicks)
  end

  -- stash selection for inserting later
  self.dnd_sText = dnd.getSelectedText(self.doc)
  -- disable blinking caret and stash user setting
  self.dnd_bBlink = config.disable_blink
  config.disable_blink = true
end -- DocView:on_mouse_pressed


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
      dnd.reset(self)
    end
    return on_mouse_released(self, button, x, y)
  end

  local bDuplicating = keymap.modkeys['ctrl']
  if self:dnd_isInSelections(iLine, iCol, bDuplicating) then
    -- drag abborted by releasing mouse inside selection
    self.doc:remove_selection(self.doc.last_selection)
  else
    -- do some calculations for selecting inserted text
    local iAdditionalLines, sLast = -1, ''
    for s in (self.dnd_sText .. "\n"):gmatch("(.-)\n") do
      iAdditionalLines = iAdditionalLines + 1
      sLast = s
    end
    local iLastLength = #sLast
    -- have doc handle selection updates
    self.doc:insert(iLine, iCol, self.dnd_sText)
    -- add a marker so we know where to start selecting pasted text
    self.doc:add_selection(iLine, iCol)
    if not bDuplicating then
      self.doc:delete_to(0)
    end
    -- get new location of inserted text
    iLine, iCol = self.doc:get_selection_idx(self.doc.last_selection, true)
    local iLine2, iCol2 = iLine + iAdditionalLines
    if iLine == iLine2 then
      iCol2 = iCol + iLastLength
    else
      iCol2 = iLastLength + 1
    end
    -- finally select inserted text
    self.doc:set_selection(iLine, iCol, iLine2, iCol2)
  end
  -- unset stashes and flag
  dnd.reset(self)
  return on_mouse_released(self, button, x, y)
end -- DocView:on_mouse_released


local draw_caret = DocView.draw_caret
function DocView:draw_caret(x, y)
  if self.dnd_sText and config.plugins.dragdropselected.enabled then
    local iLine, iCol = self:resolve_screen_position(x, y)
    -- don't show carets inside selections
    if self:dnd_isInSelections(iLine, iCol, true) then
      return
    end
  end
  draw_caret(self, x, y)
end -- DocView:draw_caret()


-- catch escape-key presses
local on_key_released = keymap.on_key_released
function keymap.on_key_released(k)
  if config.plugins.dragdropselected.enabled and 'escape' == k then
    dnd.reset()
  end
  return on_key_released(k)
end


return dnd

