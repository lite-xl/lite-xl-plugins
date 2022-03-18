-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"

config.plugins.smoothcaret = { rate = 0.65 }

local docview_update = DocView.update
function DocView:update()
  docview_update(self)

  local minline, maxline = self:get_visible_line_range()

  -- We need to keep track of all the carets
  if not self.carets then
    self.carets = { }
  end
  -- and we need the list of visible ones that `DocView:draw_caret` will use in succession
  self.visible_carets = { }

  local idx, v_idx = 1, 1
  for _, line, col in self.doc:get_selections() do
    local x, y = self:get_line_screen_position(line)
    -- Keep the position relative to the whole View
    -- This way scrolling won't animate the caret
    x = x + self:get_col_x_offset(line, col) + self.scroll.x
    y = y + self.scroll.y

    if not self.carets[idx] then
      self.carets[idx] = { current = { x = x, y = y }, target = { x = x, y = y } }
    end

    local c = self.carets[idx]
    c.target.x = x
    c.target.y = y

    -- Chech if the number of carets changed
    if self.last_n_selections ~= #self.doc.selections then
      -- Don't animate when there are new carets
      c.current.x = x
      c.current.y = y
    else
      self:move_towards(c.current, "x", c.target.x, config.plugins.smoothcaret.rate)
      self:move_towards(c.current, "y", c.target.y, config.plugins.smoothcaret.rate)
    end

    -- Keep track of visible carets
    if line >= minline and line <= maxline then
      self.visible_carets[v_idx] = self.carets[idx]
      v_idx = v_idx + 1
    end
    idx = idx + 1
  end
  self.last_n_selections = #self.doc.selections

  -- Remove unused carets to avoid animating new ones when they are added
  for i = idx, #self.carets do
    self.carets[idx] = nil
  end

  if self.mouse_selecting ~= self.last_mouse_selecting then
    self.last_mouse_selecting = self.mouse_selecting
    -- Show the caret on click, so that it can be seen moving towards the new position
    if self.mouse_selecting then
      core.blink_timer = core.blink_timer + config.blink_period / 2
      core.redraw = true
    end
  end

  -- This is used by `DocView:draw_caret` to keep track of the current caret
  self.caret_idx = 1
end

function DocView:draw_caret(x, y)
  local c = self.visible_carets[self.caret_idx] or { current = { x = x, y = y } }
  local lh = self:get_line_height()

  -- We use the scroll position to move back to the position relative to the window
  renderer.draw_rect(c.current.x - self.scroll.x, c.current.y - self.scroll.y, style.caret_width, lh, style.caret)

  self.caret_idx = self.caret_idx + 1
end
