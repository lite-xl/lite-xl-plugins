--[[
    dragdropselected.lua
    provides basic drag and drop of selected text (in same document)
    version: 20200627_133351
    originally by SwissalpS

    TODO: use OS drag and drop events
    TODO: change mouse cursor when duplicating
    TODO: add dragging image
--]]
local DocView = require "core.docview"
local core = require "core"
local keymap = require "core.keymap"

-- helper function for on_mouse_pressed to determine if mouse down is in selection
-- iLine is line number where mouse down happened
-- iCol is column where mouse down happened
-- iSelLine1 is line number where selection starts
-- iSelCol1 is column where selection starts
-- iSelLine2 is line number where selection ends
-- iSelCol2 is column where selection ends
local function isInSelection(iLine, iCol, iSelLine1, iSelCol1, iSelLine2, iSelCol2)
    if iLine < iSelLine1 then return false end
    if iLine > iSelLine2 then return false end
    if (iLine == iSelLine1) and (iCol < iSelCol1) then return false end
    if (iLine == iSelLine2) and (iCol > iSelCol2) then return false end
    return true
end -- isInSelection

-- override DocView:on_mouse_moved
local on_mouse_moved = DocView.on_mouse_moved
function DocView:on_mouse_moved(x, y, ...)

    local sCursor = nil

    -- make sure we only act if previously on_mouse_pressed was in selection
    if self.bClickedIntoSelection then

        -- show that we are dragging something
        sCursor = 'hand'

        -- check for modifier to duplicate
        -- (may want to set a flag as this only needs to be done once)
        -- TODO: make image to drag with and/or hand over to OS dnd event
        if not keymap.modkeys['ctrl'] then
            -- TODO: maybe check if moved at all and only delete then or
            -- as some editors do, only when dropped. I do like it going
            -- instantly as that reduces the travel-distance.
            self.doc:delete_to(0)
            --sCursor = 'arrowWithPlus' -- 'handWithPlus'
        end

        -- calculate line and column for current mouse position
        local iLine, iCol = self:resolve_screen_position(x, y)
        -- move text cursor
        self.doc:set_selection(iLine, iCol)
        -- update scroll position
        self:scroll_to_line(iLine, true)

    end -- if previously clicked into selection

    -- hand off to 'old' on_mouse_moved()
    on_mouse_moved(self, x, y, ...)
    -- override cursor as needed
    if sCursor then self.cursor = sCursor end

end -- DocView:on_mouse_moved

-- override DocView:on_mouse_pressed
local on_mouse_pressed = DocView.on_mouse_pressed
function DocView:on_mouse_pressed(button, x, y, clicks)

    -- no need to proceed if not left button or has no selection
    if ('left' ~= button)
      or (not self.doc:has_selection())
      or (1 < clicks) then
        return on_mouse_pressed(self, button, x, y, clicks)
    end
    -- convert pixel coordinates to line and column coordinates
    local iLine, iCol = self:resolve_screen_position(x, y)
    -- get selection coordinates
    local iSelLine1, iSelCol1, iSelLine2, iSelCol2 = self.doc:get_selection(true)
    -- set flag for on_mouse_released and on_mouse_moved() methods to detect dragging
    self.bClickedIntoSelection = isInSelection(iLine, iCol, iSelLine1, iSelCol1,
                                               iSelLine2, iSelCol2)
    if self.bClickedIntoSelection then
        -- stash selection for inserting later
        self.sDraggedText = self.doc:get_text(self.doc:get_selection())
    else
        -- let 'old' on_mouse_pressed() do whatever it needs to do
        on_mouse_pressed(self, button, x, y, clicks)
    end

end -- DocView:on_mouse_pressed

-- override DocView:on_mouse_released()
local on_mouse_released = DocView.on_mouse_released
function DocView:on_mouse_released(button)

    if self.bClickedIntoSelection then
        -- insert stashed selected text at current position
        self.doc:text_input(self.sDraggedText)
        -- unset stash and flag(s) TODO:
        self.sDraggedText = ''
        self.bClickedIntoSelection = nil
    end

    -- hand over to old handler
    on_mouse_released(self, button)

end -- DocView:on_mouse_released

