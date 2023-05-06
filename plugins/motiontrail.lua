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

local function get_caret_size(dv, i)
  local line, col = dv.doc:get_selection_idx(i)
  local chw = dv:get_font():get_width(dv.doc:get_char(line, col))
  local w = style.caret_width
  local h = dv:get_line_height()

  if cc_installed then
    local cc_shape = cc_conf.shape
    if cc_shape == "underline" or dv.doc.overwrite then
      w = chw
      h = style.caret_width * 2
    elseif cc_shape ==  "block" then
      w = chw
    end
  end

  return w, h
end

local caret_idx, caret_amt = 1, 0

local dv_update = DocView.update
function DocView:update()
  self.last_pos = self.last_pos or {}
  self.last_view = self.last_view or {}
  self.last_doc_pos = self.last_doc_pos or {}
  caret_idx = caret_idx or 1

  -- continue from whatever caret_idx left
  caret_amt = caret_amt and math.max(caret_amt, caret_idx) or 0
  for i=1, caret_amt - caret_idx do
    local ri = caret_idx + i
    self.last_pos[ri] = nil
    self.last_view[ri] = nil
    self.last_doc_pos[ri] = nil
  end
  caret_idx = 1
  dv_update(self)
end

local dv_draw = DocView.draw
function DocView:draw()
  self.draws = self.draws and self.draws + 1 or 1
  return dv_draw(self)
end

local dv_draw_caret = DocView.draw_caret
function DocView:draw_caret(x, y)
  if not config.plugins.motiontrail.enabled or self ~= core.active_view then
    dv_draw_caret(self, x, y)
    return
  end

  self.last_pos[caret_idx] = self.last_pos[caret_idx] or {}
  self.last_doc_pos[caret_idx] = self.last_doc_pos[caret_idx] or {}
  local line, col = self.doc:get_selection_idx(caret_idx)

  if self.draws <= 1 then
    local lsx, lsy = self.last_pos[caret_idx][1] or x, self.last_pos[caret_idx][2] or y
    local lsl, lsc = self.last_doc_pos[caret_idx][1], self.last_doc_pos[caret_idx][2]
    local w, h = get_caret_size(self, caret_idx)

    if self.difference_in_coords and lsx == x and lsy == y then
      self.difference_in_coords = false
    end

    if lsl ~= line or lsc ~= col then self.difference_in_coords = true end

    if self.difference_in_coords and self.last_view[caret_idx] == self then
      local lx = x
      for i = 0, 1, 1 / config.plugins.motiontrail.steps do
        local ix = common.lerp(x, lsx, i)
        local iy = common.lerp(y, lsy, i)
        if cc_installed and cc_conf.shape == "underline" or self.doc.overwrite then
          iy = iy + self:get_line_height()
        end
        local iw = math.max(w, math.ceil(math.abs(ix - lx)))
        local color = style.caret
        if cc_installed and cc_conf.custom_color then
          color = cc_conf.caret_color
        end
        renderer.draw_rect(ix, iy, iw, h, color)
        lx = ix
      end
      core.redraw = true
    end
  end

  self.last_pos[caret_idx][1], self.last_pos[caret_idx][2], self.last_view[caret_idx] = x, y, self
  self.last_doc_pos[caret_idx][1], self.last_doc_pos[caret_idx][2] = line, col
  caret_idx = caret_idx + 1
  self.draws = 0
  dv_draw_caret(self, x, y)
end
