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

local cc_installed = pcall(require, 'plugins.custom_caret')
local cc_conf = config.plugins.custom_caret

local function lerp(a, b, t)
  if not (a and b and t) then return 0 end
  return a + (b - a) * t
end

local caret_index = 1

local function get_caret_rect(dv)
  local line, col = dv.doc:get_selection_idx(caret_index)
  local chw = dv:get_font():get_width(dv.doc:get_char(line, col))
   local w = style.caret_width
  local h = dv:get_line_height()

  if cc_installed then
    local cc_shape = cc_conf.shape
    if cc_shape ==  "block" then
      w = chw
    elseif cc_shape == "underline" then
      w = chw
      h = style.caret_width * 2
    end
  end

  return w, h
end

local last_x, last_y, last_view = {}, {}, {}

local dv_update = DocView.update
function DocView:update()
  caret_index = 1
  dv_update(self)
end

local dv_draw_caret = DocView.draw_caret
function DocView:draw_caret(x,y)
  if not config.plugins.motiontrail.enabled or self ~= core.active_view then
    dv_draw_caret(self, x, y)
    return
  end

  local lsw, lsx, lsy = last_view[caret_index], last_x[caret_index], last_y[caret_index]
  local w, h = get_caret_rect(self)

  if lsw == self and (x ~= lsx or y ~= lsy) then
    local lx = x
    for i = 0, 1, 1 / config.plugins.motiontrail.steps do
      local ix = lerp(x, lsx, i)
      local iy = lerp(y, lsy, i)
      if cc_conf.shape == "underline" then iy = iy + self:get_line_height() end
      local iw = math.max(w, math.ceil(math.abs(ix - lx)))
      renderer.draw_rect(ix, iy, iw, h, (cc_conf and cc_conf.custom_color) and cc_conf.caret_color or style.caret)
      lx = ix
    end
    core.redraw = true
  end

  last_view[caret_index], last_x[caret_index], last_y[caret_index] = self, x, y

  caret_index = caret_index + 1

  dv_draw_caret(self, x,y)
end
