-- mod-version:3
local core = require "core"
local DocView = require "core.docview"
local style = require "core.style"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"

local SS = {}

-- Ignore lines with only the opening bracket
function SS.get_level_ignore_open_bracket(doc, line)
  if doc.lines[line]:match("^%s*{%s*$") then
    return -1
  end
  return SS.get_level_default(doc, line)
end

local filetype_overrides = {
  ["Markdown"] = function(doc, line)
    -- Use the markdown heading level only
    local indent = string.match(doc.lines[line], "^#+() .+")
    return indent or math.huge
  end,
  ["C"] = SS.get_level_ignore_open_bracket,
  ["C++"] = SS.get_level_ignore_open_bracket,
  ["Plain Text"] = false
}

config.plugins.sticky_scroll = common.merge({
  enabled = true,
  max_sticky_lines = 5,
  -- Override the function to get the level of a line.
  --
  -- The key is the syntax name, the value is a function that receives the doc
  -- and the line, and returns the level [-1; math.huge].
  --
  -- The default function is `SS.get_level_default`, which is indent based,
  -- and ignores comment-only lines.
  -- Use `false` to disable the plugin for that filetype.
  filetype_overrides = filetype_overrides,
  config_spec = {
    name = "Sticky Scroll",
    {
      label = "Enabled",
      description = "Enable or disable drawing the Sticky Scroll.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Maximum number of sticky lines",
      description = "The maximum number of sticky lines to show",
      path = "max_sticky_lines",
      type = "number",
      default = 5,
      min = 1,
      step = 1
    }
  }
}, config.plugins.sticky_scroll)

-- Merge user changes with the default overrides
config.plugins.sticky_scroll.filetype_overrides = common.merge(filetype_overrides, config.plugins.sticky_scroll.filetype_overrides)


-- Automatically remove docview (keys) when not needed anymore
-- Automatically create a docview entry on access
SS.managed_docviews = setmetatable({}, {
  __mode = "k",
  __index = function(t, k)
      local v = {enabled = true, sticky_lines = {}, reference_line = 1, syntax = nil}
      rawset(t, k, v)
      return v
    end
})

local regex_pattern = regex.compile([[(\s*)\S]])
---Return the indent level of a string.
---The indent level is counted as the number of spaces and tabs in the string.
---A tab is counted as a space, so mixed tab types can cause issues.
---
---TODO: maybe only consider the indent type of the file,
---      or even only consider valid the type of the first character in the line.
---
---@param doc core.doc
---@param line integer
---@return integer #>0 for lines with indents and text, 0 for lines with no indent, -1 for lines without any non-whitespace characters
function SS.get_level_from_indent(doc, line)
  local text = doc.lines[line]
  local s, e = regex.find_offsets(regex_pattern --[[@as regex]], text)
  return s and e - s or -1
end

---Same as SS.get_level_from_indent, but ignores lines with only comments.
---@param doc core.doc
---@param line integer
---@return integer #>0 for lines with indents and text, 0 for lines with no indent, -1 for lines without any non-whitespace characters
function SS.get_level_default(doc, line)
  for _, type, text in doc.highlighter:each_token(line) do
    if type ~= "comment" then
      return SS.get_level_from_indent(doc, line)
    end
  end
  return -1
end

---Return the function to use to get the level.
---
---@param doc core.doc
---@param line integer
---@return function
function SS.get_level_getter(doc)
  local get_level = SS.get_level_default
  if config.plugins.sticky_scroll
   and doc.syntax.name
   and config.plugins.sticky_scroll.filetype_overrides[doc.syntax.name] ~= nil then
    get_level = config.plugins.sticky_scroll.filetype_overrides[doc.syntax.name]
    if get_level == false then
      get_level = nil
    end
  end
  return get_level
end

---Returns whether the plugin is enabled.
---If `dv` is provided, returns if the docview is enabled.
---The "global" check has priority over the docview check.
---
---@param dv core.docview?
---return boolean
function SS.should_run(dv)
  if dv and not dv:is(DocView) then return false end
  if dv and not SS.managed_docviews[dv].enabled then return false end
  if not config.plugins.sticky_scroll or not config.plugins.sticky_scroll.enabled then return false end
  return true
end

---Return an array of the sticly lines that should be shown.
---
---@param doc core.doc
---@param start_line integer #the reference line
---@param max_sticky_lines integer #the maximum allowed sticky lines
---@return table #an ordered list of lines that should be shown as sticky
function SS.get_sticky_lines(doc, start_line, max_sticky_lines)
  local res = {}
  local last_level
  local original_start_line = start_line
  start_line = common.clamp(start_line, 1, #doc.lines)

  local get_level = SS.get_level_getter(doc)
  if not get_level then return res end

  -- Find the first usable line
  repeat
    if start_line <= 0 then return res end
    last_level = get_level(doc, start_line)
    start_line = start_line - 1
  until last_level >= 0

  -- If we had to skip some lines, check if we need to stick the usable one
  if original_start_line ~= start_line + 1 then
    local found = false
    -- Check if there are valid lines after the original start line
    for i = original_start_line, #doc.lines do
      local next_indent_level = get_level(doc, i)
      if next_indent_level >= 0 then
        if next_indent_level == 0 and next_indent_level < last_level then
          -- We are at the end of the block,
          -- so there aren't any sticky lines to be shown
          return res
        end
        -- If there is an indent level higher than original start line,
        -- stick the usable line that was found
        if next_indent_level > last_level then
          table.insert(res, start_line + 1)
        end
        found = true
        break
      end
    end
    -- If there are no valid lines, we don't need to show sticky lines.
    if not found then return res end
  end

  -- Find sticky lines to show, starting from the current line,
  -- until we get to one that has level 0.
  for i = start_line, 1, -1 do
    local level = get_level(doc, i)
    if level >= 0 and level < last_level then
      table.insert(res, i)
      last_level = level
    end
    if level == 0 then break end
  end

  -- Only keep the lines we're allowed to show
  common.splice(res, 1, math.max(0, #res - max_sticky_lines))
  return res
end

-- TODO: Workaround - Remove when lite-xl/lite-xl#1382 is merged and released
local function get_visible_line_range(dv)
  local _, y, _, y2 = dv:get_content_bounds()
  local lh = dv:get_line_height()
  local minline = math.max(1, math.floor((y - style.padding.y) / lh) + 1)
  local maxline = math.min(#dv.doc.lines, math.floor((y2 - style.padding.y) / lh) + 1)
  return minline, maxline
end

local last_max_sticky_lines
local old_dv_update = DocView.update
function DocView:update(...)
  local res = old_dv_update(self, ...)
  if not SS.should_run(self) then return res end

  -- Simple cache. Gets reset on every doc change.
  -- Could be made smarter, but this will do for now™.
  local docview = SS.managed_docviews[self]
  local current_change_id = self.doc:get_change_id()
  if docview.sticky_scroll_last_change_id ~= current_change_id
   or last_max_sticky_lines ~= config.plugins.sticky_scroll.max_sticky_lines
   or docview.syntax ~= self.doc.syntax then
    docview.sticky_scroll_cache = {}
    docview.reference_line = 1
    docview.syntax = self.doc.syntax
    docview.sticky_scroll_last_change_id = current_change_id
    last_max_sticky_lines = config.plugins.sticky_scroll.max_sticky_lines
  end

  local minline, _ = get_visible_line_range(self)
  local lh = self:get_line_height()

  -- We need to find the first line that'll be visible
  -- even after the sticky lines are drawn.
  local from = math.max(1, minline)
  local to = math.min(minline + config.plugins.sticky_scroll.max_sticky_lines, #self.doc.lines)
  local new_sticky_lines = {}
  local new_reference_line = to
  for i = from, to do
    -- Simple cache
    if not docview.sticky_scroll_cache[i] then
      docview.sticky_scroll_cache[i] = SS.get_sticky_lines(self.doc, i, config.plugins.sticky_scroll.max_sticky_lines)
    end
    local scroll_lines = docview.sticky_scroll_cache[i]
    local _, nl_y = self:get_line_screen_position(i)
    if nl_y >= self.position.y + lh * #scroll_lines then
      break
    end
    new_sticky_lines = scroll_lines
    new_reference_line = i
  end

  docview.sticky_lines = new_sticky_lines
  docview.reference_line = new_reference_line
  return res
end

local old_dv_draw_overlay = DocView.draw_overlay
function DocView:draw_overlay(...)
  local res = old_dv_draw_overlay(self, ...)
  if not SS.should_run(self) then return res end

  local minline, _ = get_visible_line_range(self)
  local lh = self:get_line_height()

  -- Ignore the horizontal scroll position when drawing sticky lines
  local scroll_x = self.scroll.x
  self.scroll.x = 0
  local x = self:get_line_screen_position(minline)
  self.scroll.x = scroll_x

  local y
  local gw, gpad = self:get_gutter_width()
  local data = SS.managed_docviews[self]
  local _, rl_y = self:get_line_screen_position(data.reference_line)

  -- We need to reset the clip, because when DocView:draw_overlay is called
  -- it's too small for us.
  local old_clip_rect = core.clip_rect_stack[#core.clip_rect_stack]
  renderer.set_clip_rect(self.position.x, self.position.y, self.size.x, self.size.y)

  local drawn = false
  local max_y = 0
  for i=1, #data.sticky_lines do
    y = self.position.y + (#data.sticky_lines - i) * lh
    local l = data.sticky_lines[i]
    y = math.min(y, rl_y)
    max_y = math.max(y, max_y)
    drawn = true
    renderer.draw_rect(self.position.x, y, self.size.x, lh, style.background)
    self:draw_line_gutter(l, self.position.x, y, gpad and gw - gpad or gw)
    self:draw_line_text(l, x, y)
    if data.hovered_sticky_scroll_line == l then
      renderer.draw_rect(self.position.x, y, self.size.x, lh, style.drag_overlay)
    end
  end
  if drawn then
    renderer.draw_rect(self.position.x, max_y + lh, self.size.x, style.divider_size, style.divider)
  end

  -- Restore clip rect
  renderer.set_clip_rect(table.unpack(old_clip_rect))
  return res
end

local old_mouse_pressed = DocView.on_mouse_pressed
function DocView:on_mouse_pressed(button, x, y, clicks, ...)
  if not SS.should_run(self) then return old_mouse_pressed(self, button, x, y, clicks, ...) end

  local data = SS.managed_docviews[self]
  data.sticky_lines_mouse_pressed = false
  if #data.sticky_lines == 0 then
    return old_mouse_pressed(self, button, x, y, clicks, ...)
  end

  local lh = self:get_line_height()
  local rl_x, rl_y = self:get_line_screen_position(data.reference_line)
  if y >= math.min(rl_y + lh, lh * #data.sticky_lines + self.position.y) or y < self.position.y then
    data.sticky_lines_mouse_pressed = true
    return old_mouse_pressed(self, button, x, y, clicks, ...)
  end

  local clicked_line = data.sticky_lines[#data.sticky_lines - (y - self.position.y) // lh]
  local col = self:get_x_offset_col(clicked_line, x - rl_x)
  self:scroll_to_make_visible(clicked_line, col)
  self.doc:set_selection(clicked_line, col)
  return true
end

local old_mouse_moved = DocView.on_mouse_moved
function DocView:on_mouse_moved(x, y, ...)
  if not SS.should_run(self) then return old_mouse_moved(self, x, y, ...) end

  local data = SS.managed_docviews[self]
  data.hovered_sticky_scroll_line = nil
  if #data.sticky_lines == 0 then
    return old_mouse_moved(self, x, y, ...)
  end

  local lh = self:get_line_height()
  local _, rl_y = self:get_line_screen_position(data.reference_line)
  if self.mouse_selecting
   or y >= math.min(rl_y + lh, lh * #data.sticky_lines + self.position.y)
   or y < self.position.y
   or x < self.position.x
   or x >= self.position.x + self.size.x
   or self.v_scrollbar:overlaps(x, y)
   then
    return old_mouse_moved(self, x, y, ...)
  end

  self.cursor = "hand"
  data.hovered_sticky_scroll_line = data.sticky_lines[#data.sticky_lines - (y - self.position.y) // lh]
  return true
end

local old_scroll_to_make_visible = DocView.scroll_to_make_visible
function DocView:scroll_to_make_visible(line, col, ...)
  old_scroll_to_make_visible(self, line, col, ...)
  if not SS.should_run(self) then return end

  -- We need to scroll the view to account for the sticky lines.

  local lh = self:get_line_height()
  local before_scroll = self.scroll.y
  local _, ly = self:get_line_screen_position(line, col)
  ly = ly - self.position.y + (before_scroll - self.scroll.to.y)
  local data = SS.managed_docviews[self]
  -- Avoid moving the caret under the sticky lines.
  local num_sticky_lines
  if data.sticky_lines_mouse_pressed or self.mouse_selecting then
    -- On mouse click, use the current number of visible sticky lines
    -- to avoid scrolling too much.
    data.sticky_lines_mouse_pressed = false
    num_sticky_lines = data.sticky_lines and #data.sticky_lines or 0
  else
    -- When the movement wasn't caused by mouse clicks, use the maximum number
    -- of possible sticky lines, to avoid scrolling in an inconsistent way
    -- when adjusting for the changing number of sticky lines.
    num_sticky_lines = config.plugins.sticky_scroll.max_sticky_lines
  end
  if ly < num_sticky_lines * lh then
    self.scroll.to.y = self.scroll.to.y - ((num_sticky_lines * lh) - ly)
  end
end

-- Generic commands
command.add(function() return config.plugins.sticky_scroll end, {
  ["sticky-lines:toggle"] = function()
    config.plugins.sticky_scroll.enabled = not config.plugins.sticky_scroll.enabled
  end
})
command.add(function() return config.plugins.sticky_scroll and not config.plugins.sticky_scroll.enabled end, {
  ["sticky-lines:enable"] = function()
    config.plugins.sticky_scroll.enabled = true
  end
})
command.add(function() return config.plugins.sticky_scroll and config.plugins.sticky_scroll.enabled end, {
  ["sticky-lines:disable"] = function()
    config.plugins.sticky_scroll.enabled = false
  end
})

-- Per-docview commands
command.add(SS.should_run, {
  ["sticky-lines:toggle-doc"] = function()
    local dv = core.active_view
    SS.managed_docviews[dv].enabled = not SS.managed_docviews[dv].enabled
  end
})
command.add(function()
    local dv = core.active_view
    return SS.should_run() and not SS.managed_docviews[dv].enabled, dv
  end, {
  ["sticky-lines:enable-doc"] = function(dv)
    SS.managed_docviews[dv].enabled = true
  end
})
command.add(function()
    local dv = core.active_view
    return SS.should_run() and SS.managed_docviews[dv].enabled, dv
  end, {
  ["sticky-lines:disable-doc"] = function(dv)
    SS.managed_docviews[dv].enabled = false
  end
})

return SS
