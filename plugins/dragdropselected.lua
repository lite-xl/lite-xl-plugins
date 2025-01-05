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
  thanks to: github.com/Guldoman for his valuable inputs while I was re-writing
             this plugin for lite-xl. The plugin turned out a lot better and
             thus the backport for lite also turned out better.
  original: 20200627_133351 by SwissalpS

  TODO: use OS drag and drop events (unlikely to happen, more important is
        dragging between views of same instance.)
  TODO: change mouse cursor when duplicating (requires change in cpp/SDL2)
--]]
local core = require "core"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"
local keymap = require "core.keymap"
local style = require "core.style"

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
function DocView:dnd_isInSelections(iX, iY, bDuplicating)
  self.dnd_lSelections = self.dnd_lSelections or self:dnd_collectSelections()
  if not self.dnd_lSelections then return nil end

  local iLine, iCol = self:resolve_screen_position(iX, iY)
  if config.plugins.dragdropselected.useSticky and not self.dnd_bDragging then
    -- allow user to clear selection in sticky mode by clicking in empty area
    -- to the right of selection
    local iX2 = self:get_line_screen_position(iLine, #self.doc.lines[iLine])
    -- this does not exactly corespond with the graphical selected area
    -- it means selection can't be grabbed by the "\n" at the end
    if iX2 < iX then return nil end
  end

  local iLine1, iCol1, iLine2, iCol2
  local i = #self.dnd_lSelections
  repeat
    iLine1, iCol1, iLine2, iCol2 = table.unpack(self.dnd_lSelections[i])
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

  if dnd.oGhost then dnd.oGhost:hide() end
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
    return on_mouse_moved(self, x, y, ...)
  end

  -- not sure we need to do this or if we better not
  DocView.super.on_mouse_moved(self, x, y, ...)

  if self.dnd_bDragging then
    -- remove last caret showing insert location
    self.doc:remove_selection(self.doc.last_selection)
    -- move ghost, if available and activated
    if dnd.oGhost and config.plugins.dragdropselected.useGhost then
      dnd.oGhost:set_position(x + 22, y + 11)
      if self.dnd_bMouseLeft then
        self.dnd_bMouseLeft = nil
        dnd.oGhost:show()
      end
    end
  else
    self.dnd_bDragging = true
    -- show that we are dragging something
    self.cursor = 'hand'
    -- make sure selections are marked
    self:dnd_setSelections()
    -- initiate ghost, if available and activated
    if dnd.oGhost and config.plugins.dragdropselected.useGhost then
      dnd.oGhost:set_position(x + 22, y + 11)
      dnd.oGhost:show()
    end
  end
  -- calculate line and column for current mouse position
  local iLine, iCol = self:resolve_screen_position(x, y)
  -- show insert location
  self.doc:add_selection(iLine, iCol)
  -- update scroll position, if needed
  self:scroll_to_line(iLine, true)
  return true
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
    or not self:dnd_isInSelections(x, y)
  then
    dnd.reset(self)
    return on_mouse_pressed(self, button, x, y, clicks)
  end

  -- stash selection for inserting later
  self.dnd_sText = dnd.getSelectedText(self.doc)
  -- prepare ghost, if available and used
  if dnd.oGhost and config.plugins.dragdropselected.useGhost then
    dnd.oGhost:set_label(dnd.split4ghost(self.dnd_sText))
  end
  -- disable blinking caret and stash user setting
  self.dnd_bBlink = config.disable_blink
  config.disable_blink = true
  return true
end -- DocView:on_mouse_pressed


local on_mouse_released = DocView.on_mouse_released
function DocView:on_mouse_released(button, x, y)
  -- nothing to do if: not enabled,
  -- never clicked into selection or not left button
  if not config.plugins.dragdropselected.enabled
    or 'left' ~= button
    or not self.dnd_sText
  then
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
  if self:dnd_isInSelections(x, y, bDuplicating) then
    -- drag aborted by releasing mouse inside selection
    self.doc:remove_selection(self.doc.last_selection)
  else
    -- have doc handle selection updates
    self.doc:insert(iLine, iCol, self.dnd_sText)
    -- add a marker so we know where to start selecting pasted text
    self.doc:add_selection(iLine, iCol)
    if not bDuplicating then
      self.doc:delete_to(0)
    end
    -- get new location of inserted text
    iLine, iCol = self.doc:get_selection_idx(self.doc.last_selection, true)
    -- finally select inserted text
    self.doc:set_selection(
        iLine, iCol, self.doc:position_offset(iLine, iCol, #self.dnd_sText))
  end
  -- unset stashes and flag
  dnd.reset(self)
  return on_mouse_released(self, button, x, y)
end -- DocView:on_mouse_released


local draw_caret = DocView.draw_caret
function DocView:draw_caret(x, y)
  if self.dnd_sText and config.plugins.dragdropselected.enabled then
    -- don't show carets inside selections
    if self:dnd_isInSelections(x, y, true) then
      return
    end
  end
  return draw_caret(self, x, y)
end -- DocView:draw_caret()


-- disable text_input during drag operations
local on_text_input = DocView.on_text_input
function DocView:on_text_input(text)
  if self.dnd_bDragging then
    return true
  end
  return on_text_input(self, text)
end -- DocView:on_text_input


function dnd.abort(oDocView)
  if not config.plugins.dragdropselected.enabled then return end

  if oDocView.dnd_bDragging then
    -- ensure there are no stray markers by re-selecting
    oDocView:dnd_setSelections()
  end
  dnd.reset(oDocView)
end -- dnd.abort


function dnd.abortPredicate()
  if not config.plugins.dragdropselected.enabled
    or not core.active_view:is(DocView)
    or not core.active_view.dnd_bDragging
  then return false end

  return true, core.active_view
end -- dnd.abortPredicate


function dnd.showStatus(s)
  if not core.status_view then return end

  local tS = style.log['INFO']
  core.status_view:show_message(tS.icon, tS.color, s)
end -- dnd.showStatus


function dnd.toggleEnabled()
  config.plugins.dragdropselected.enabled =
      not config.plugins.dragdropselected.enabled

  dnd.showStatus("Drag n' Drop is "
    .. (config.plugins.dragdropselected.enabled and 'en' or 'dis')
    .. 'abled')

end -- dnd.toggleEnabled


function dnd.toggleSticky()
  config.plugins.dragdropselected.useSticky =
      not config.plugins.dragdropselected.useSticky

  dnd.showStatus('Sticky mode is '
      .. (config.plugins.dragdropselected.useSticky and 'en' or 'dis')
      .. 'abled')

end -- dnd.toggleSticky


command.add(nil, {
  ['drag-drop-selected:toggle-enabled'] = dnd.toggleEnabled,
  ['drag-drop-selected:toggle-sticky'] =  dnd.toggleSticky
})

command.add(dnd.abortPredicate, { ['drag-drop-selected:abort'] = dnd.abort })
keymap.add({ ['escape'] = 'drag-drop-selected:abort' })


local hasWidgets, Widget = pcall(require, "libraries.widget")
if not hasWidgets then return dnd end


-- add ghost settings and config
config.plugins.dragdropselected = common.merge({
  -- use ghost
  useGhost = false,
  -- maximum amount of lines to show in ghost
  maxGhostLines = 1
}, config.plugins.dragdropselected)
-- we need to insert this way as common.merge can't handle this
table.insert(config.plugins.dragdropselected.config_spec, {
  label = "Use Ghost",
  description = "Cursor has ghost of dragged selection attached.",
  path = "useGhost",
  type = "toggle",
  default = true
})
table.insert(config.plugins.dragdropselected.config_spec, {
  label = "Maximum Ghost Lines",
  description = "Maximum amount of lines to show in ghost.",
  path = "maxGhostLines",
  type = "number",
  default = 1,
  min = 1,
  step = 1
})


---Split string sIn for use with ghost. Depending on how many lines user wants,
---return a string or a list of strings.
---@param sIn? string
---@return string | table
function dnd.split4ghost(sIn)
	if 'string' ~= type(sIn) then return '' end

	local iMaxLines = math.max(1, config.plugins.dragdropselected.maxGhostLines)
	if 1 == iMaxLines then return sIn end

	local lLines = {}
	local iLast, iNext = 0
	repeat
		iNext = string.find(sIn, '\n', iLast, true)
		if not iNext then
      lLines[#lLines + 1] = string.sub(sIn, iLast, -1)
			break
		end

    lLines[#lLines + 1] = string.sub(sIn, iLast, iNext)
		if #lLines >= iMaxLines then
      -- indicate to user that there is more selected than can be seen
      lLines[#lLines + 1] = '…'
      break
    end
		iLast = iNext + 1
	until false

	return lLines
end -- dnd.split4ghost


local docView_on_mouse_left = DocView.on_mouse_left
function DocView:on_mouse_left()
  if dnd.oGhost and dnd.oGhost:is_visible() then
    dnd.oGhost:hide()
    self.dnd_bMouseLeft = true
  end
  return docView_on_mouse_left(self)
end -- DocView:on_mouse_left


---@class Ghost : widget
local Ghost = Widget:extend()

---Constructor
function Ghost:new()
  Ghost.super.new(self, nil, true)

  self.border = { width = 0 }
  self.clickable = false
  self.custom_size = { x = 0, y = 0 }
  self.draggable = false
  self.font = 'code_font'
  local r, g, b, a = table.unpack(style.text)
  self.foreground_color = { r, g, b, math.floor(a * .77 + .5) }
  self.render_background = false
  self.scrollable = false
  self.type_name = 'dragdropselected.ghostWidget'
end -- Ghost:new


-- Ignore mouse movements.
function Ghost.on_mouse_moved() return false end


---@param width? integer
---@param height? integer
function Ghost:set_size(width, height)
  Ghost.super.set_size(self, width, height)
  self.custom_size.x = self.size.x
  self.custom_size.y = self.size.y
end -- Ghost:set_size


---Set the label text and recalculate the widget size.
---@param text string | widget.styledtext
function Ghost:set_label(text)
  Ghost.super.set_label(self, text)

  local font = self:get_font()

  if self.custom_size.x <= 0 then
    if type(text) == "table" then
      self.size.x, self.size.y = self:draw_styled_text(text, 0, 0, true)
    else
      self.size.x = font:get_width(self.label)
      self.size.y = font:get_height()
    end
  end
end -- Ghost:set_label


function Ghost:update()
  if not Ghost.super.update(self) then return false end

  if self.custom_size.x <= 0 then
    -- update the size
    self:set_label(self.label)
  end

  return true
end -- Ghost:update


function Ghost:draw()
  if not self:is_visible() then return false end

  if type(self.label) == "table" then
    self:draw_styled_text(self.label, self.position.x, self.position.y)
  else
    renderer.draw_text(
      self:get_font(),
      self.label,
      self.position.x,
      self.position.y,
      self.foreground_color or style.text
    )
  end

  return true
end -- Ghost:draw


---@type Ghost
dnd.oGhost = Ghost()


-- Toggle ghost usage and show status.
function dnd.toggleGhost()
  config.plugins.dragdropselected.useGhost =
      not config.plugins.dragdropselected.useGhost

  dnd.showStatus('Ghost is '
      .. (config.plugins.dragdropselected.useGhost and 'en' or 'dis')
      .. 'abled')

end -- dnd.toggleGhost


command.add(nil, {
  ['drag-drop-selected:toggle-ghost'] = dnd.toggleGhost
})

return dnd

