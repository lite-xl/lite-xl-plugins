-- mod-version:2 -- lite-xl 2.0
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
local style = require "core.style"

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

-- distance between two points
local function distance(x1, y1, x2, y2)
    return math.sqrt(math.pow(x2-x1, 2)+math.pow(y2-y1, 2))
end

local min_drag = style.code_font:get_width(" ")

-- override DocView:on_mouse_moved
local on_mouse_moved = DocView.on_mouse_moved
function DocView:on_mouse_moved(x, y, ...)

    local sCursor = nil

    -- make sure we only act if previously on_mouse_pressed was in selection
    if self.bClickedIntoSelection and
       ( -- we are already dragging or we moved enough to start dragging
         not self.drag_start_loc or
         distance(self.drag_start_loc[1],self.drag_start_loc[2], x, y) > min_drag
       ) then
        self.drag_start_loc = nil

        -- show that we are dragging something
        sCursor = 'hand'

        -- calculate line and column for current mouse position
        local iLine, iCol = self:resolve_screen_position(x, y)
        local iSelLine1 = self.dragged_selection[1]
        local iSelCol1  = self.dragged_selection[2]
        local iSelLine2 = self.dragged_selection[3]
        local iSelCol2  = self.dragged_selection[4]
        self.doc:set_selection(iSelLine1, iSelCol1, iSelLine2, iSelCol2)
        if not isInSelection(iLine, iCol, iSelLine1, iSelCol1, iSelLine2, iSelCol2) then
            -- show cursor only if outside selection
            self.doc:add_selection(iLine, iCol)
        end
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
    local caught = DocView.super.on_mouse_pressed(self, button, x, y, clicks)
    if caught then
        return caught
    end
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
        self.drag_start_loc = { x, y }
        -- stash selection for inserting later
        self.sDraggedText = self.doc:get_text(self.doc:get_selection())
        self.dragged_selection = { iSelLine1, iSelCol1, iSelLine2, iSelCol2 }
    else
        self.bClickedIntoSelection = nil
        self.dragged_selection = nil
        -- let 'old' on_mouse_pressed() do whatever it needs to do
        on_mouse_pressed(self, button, x, y, clicks)
    end
end -- DocView:on_mouse_pressed

-- override DocView:on_mouse_released()
local on_mouse_released = DocView.on_mouse_released
function DocView:on_mouse_released(button, x, y)
    local iLine, iCol = self:resolve_screen_position(x, y)
    if self.bClickedIntoSelection then
        local iSelLine1, iSelCol1, iSelLine2, iSelCol2 = table.unpack(self.dragged_selection)
        if not self.drag_start_loc
           and not isInSelection(iLine, iCol, iSelLine1, iSelCol1, iSelLine2, iSelCol2) then
            -- insert stashed selected text at current position
            if iLine < iSelLine1 or (iLine == iSelLine1 and iCol < iSelCol1) then
                -- delete first
                self.doc:set_selection(iSelLine1, iSelCol1, iSelLine2, iSelCol2)
                if not keymap.modkeys['ctrl'] then
                    self.doc:delete_to(0)
                end
                self.doc:set_selection(iLine, iCol)
                self.doc:text_input(self.sDraggedText)
            else
                -- insert first
                self.doc:set_selection(iLine, iCol)
                self.doc:text_input(self.sDraggedText)
                self.doc:set_selection(iSelLine1, iSelCol1, iSelLine2, iSelCol2)
                if not keymap.modkeys['ctrl'] then
                    self.doc:delete_to(0)
                end
                self.doc:set_selection(iLine, iCol)
            end
        elseif self.drag_start_loc then
            -- deselect only if the drag never happened
            self.doc:set_selection(iLine, iCol)
        end
        -- unset stash and flag(s) TODO:
        self.sDraggedText = ''
        self.bClickedIntoSelection = nil
    end

    -- hand over to old handler
    on_mouse_released(self, button, x, y)

end -- DocView:on_mouse_released

-- override DocView:draw_caret()
local draw_caret = DocView.draw_caret
function DocView:draw_caret(x, y)
    if self.bClickedIntoSelection then
        local iLine, iCol = self:resolve_screen_position(x, y)
        -- don't show carets inside selections
        if isInSelection(iLine, iCol,
                         self.dragged_selection[1], self.dragged_selection[2],
                         self.dragged_selection[3], self.dragged_selection[4]) then
            return
        end
    end
    draw_caret(self, x, y)
end -- DocView:draw_caret()
