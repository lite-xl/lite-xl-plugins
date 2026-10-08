-- mod-version:3
local core = require "core"
local style = require "core.style"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local View = require "core.view"
local renderer = require "renderer"

config.plugins.bigclock = common.merge({
  time_format = "%H:%M:%S",
  date_format = "%A, %d %B %Y",
  scale = 1,

  config_spec = {
    name = "Big Clock",
    {
      label = "Time Format",
      description = "Lua os.date() format string.",
      path = "time_format",
      type = "string",
      default = "%H:%M:%S"
    },
    {
      label = "Date Format",
      description = "Lua os.date() format string.",
      path = "date_format",
      type = "string",
      default = "%A, %d %B %Y",
    },
    {
      label = "Scale",
      description = "Overall scale multiplier.",
      path = "scale",
      type = "number",
      default = 1,
      min = 0.5,
      max = 3.0,
      step = 0.1
    }
  }
}, config.plugins.bigclock)

local ClockView = View:extend()

function ClockView:new()
  ClockView.super.new(self)
  self.time_text = ""
  self.date_text = ""
  self.last_w = 0
  self.last_h = 0
  self.last_scale = 0
end

function ClockView:get_name()
  return "Big Clock"
end

-------------------------------------------------------
-- Font fitting utility
-------------------------------------------------------
local function fit_font(base_font, text, max_width, max_height, scale)
  local size = math.floor(math.min(max_width, max_height) * 0.6 * scale)
  size = math.max(24, size)

  local font = renderer.font.copy(base_font, size)

  -- Shrink until it fits horizontally and vertically
  while size > 16 do
    if font:get_width(text) <= max_width and
       font:get_height() <= max_height then
      break
    end
    size = size - 4
    font = renderer.font.copy(base_font, size)
  end

  return font, size
end

-------------------------------------------------------
-- Responsive font update
-------------------------------------------------------
function ClockView:update_fonts()
  local w = math.floor(self.size.x)
  local h = math.floor(self.size.y)
  local scale = config.plugins.bigclock.scale

  -- Recompute only if something changed
  if w == self.last_w and h == self.last_h and scale == self.last_scale then
    return
  end

  self.last_w = w
  self.last_h = h
  self.last_scale = scale

  local padding = style.padding * 2
  local usable_w = w - padding
  local usable_h = h - padding

  -- Allocate ~70% height for time, 30% for date
  local time_h = usable_h * 0.7
  local date_h = usable_h * 0.3

  self.time_font = fit_font(
    style.font,
    self.time_text ~= "" and self.time_text or "00:00:00",
    usable_w,
    time_h,
    scale
  )

  self.date_font = fit_font(
    style.font,
    self.date_text ~= "" and self.date_text or "Wednesday, 01 January 2026",
    usable_w,
    date_h,
    scale * 0.9
  )
end

-------------------------------------------------------
-- Update clock text
-------------------------------------------------------
function ClockView:update()
  local time_text = os.date(config.plugins.bigclock.time_format)
  local date_text = os.date(config.plugins.bigclock.date_format)

  if self.time_text ~= time_text or self.date_text ~= date_text then
    self.time_text = time_text
    self.date_text = date_text
    core.redraw = true
  end

  ClockView.super.update(self)
end

-------------------------------------------------------
-- Draw
-------------------------------------------------------
function ClockView:draw()
  self:update_fonts()
  self:draw_background(style.background)

  local x, y = self.position.x, self.position.y
  local w, h = self.size.x, self.size.y

  local padding = style.padding

  local time_area_h = h * 0.7
  local date_area_h = h * 0.3

  -- Draw time
  local _, ty = common.draw_text(
    self.time_font,
    style.text,
    self.time_text,
    "center",
    x,
    y + padding,
    w,
    time_area_h
  )

  -- Draw date
  common.draw_text(
    self.date_font,
    style.dim,
    self.date_text,
    "center",
    x,
    y + time_area_h,
    w,
    date_area_h
  )
end

-------------------------------------------------------
-- Command
-------------------------------------------------------
command.add(nil, {
  ["big-clock:open"] = function()
    local node = core.root_view:get_active_node()
    node:add_view(ClockView())
  end,
})

return ClockView
