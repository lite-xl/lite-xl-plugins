-- mod-version:3
local core = require "core"
local config = require "core.config"
local common = require "core.common"
local style = require "core.style"
local DocView = require "core.docview"

config.plugins.motiontrail = common.merge({
  enabled = true,
  steps = 50,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Motion Trail",
    {
      label = "Enabled",
      description = "Disable or enable the caret motion trail effect.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Steps",
      description = "Amount of trail steps to generate on caret movement.",
      path = "steps",
      type = "number",
      default = 50,
      min = 10,
      max = 100
    },
  }
}, config.plugins.motiontrail)


local function lerp(a, b, t)
  return a + (b - a) * t
end


local function get_caret_rect(dv)
  local line, col = dv.doc:get_selection()
  local x, y = dv:get_line_screen_position(line, col)
  return x, y, style.caret_width, dv:get_line_height()
end


local last_x, last_y, last_view

local draw = DocView.draw

function DocView:draw(...)
  draw(self, ...)
  if not config.plugins.motiontrail.enabled or self ~= core.active_view then
    return
  end

  local x, y, w, h = get_caret_rect(self)

  if last_view == self and (x ~= last_x or y ~= last_y) then
    local lx = x
    for i = 0, 1, 1 / config.plugins.motiontrail.steps do
      local ix = lerp(x, last_x, i)
      local iy = lerp(y, last_y, i)
      local iw = math.max(w, math.ceil(math.abs(ix - lx)))
      renderer.draw_rect(ix, iy, iw, h, style.caret)
      lx = ix
    end
    core.redraw = true
  end

  last_view, last_x, last_y = self, x, y
end

