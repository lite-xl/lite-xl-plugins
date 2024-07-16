-- mod-version:3
local core = require "core"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local DocView = require "core.docview"

config.plugins.smoothcaret = common.merge({
  enabled = true,
  rate = 0.65,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Smooth Caret",
    {
      label = "Enabled",
      description = "Disable or enable the smooth caret animation.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Rate",
      description = "Speed of the animation.",
      path = "rate",
      type = "number",
      default = 0.65,
      min = 0.2,
      max = 1.0,
      step = 0.05
    },
  }
}, config.plugins.smoothcaret)

local caret_idx = 1

local docview_update = DocView.update
function DocView:update()
  docview_update(self)

  if not config.plugins.smoothcaret.enabled then return end

  local minline, maxline = self:get_visible_line_range()

  -- We need to keep track of all the carets
  if not self.carets then
    self.carets = { }
  end
  -- and we need the list of visible ones that `DocView:draw_caret` will use in succession
  self.visible_carets = { }

  local idx, v_idx = 1, 1
  for _, line, col in self.doc:get_selections() do
    local x, y = self:get_line_screen_position(line, col)
    -- Keep the position relative to the whole View
    -- This way scrolling won't animate the caret
    x = x + self.scroll.x
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
    self.carets[i] = nil
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
  caret_idx = 1
end

local docview_draw_caret = DocView.draw_caret
function DocView:draw_caret(x, y)
  if not config.plugins.smoothcaret.enabled then
    docview_draw_caret(self, x, y)
    return
  end

  local c = self.visible_carets[caret_idx] or { current = { x = x, y = y } }
  docview_draw_caret(self, c.current.x - self.scroll.x, c.current.y - self.scroll.y)

  caret_idx = caret_idx + 1
end
