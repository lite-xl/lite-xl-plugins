-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local style = require "core.style"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local View = require "core.view"


config.plugins.bigclock = {
  time_format = "%H:%M:%S",
  date_format = "%A, %d %B %Y",
  scale = 1
}


local ClockView = View:extend()


function ClockView:new()
  ClockView.super.new(self)
  self.time_text = ""
  self.date_text = ""
end


function ClockView:get_name()
  return "Big Clock"
end


function ClockView:update_fonts()
  local size = math.floor(self.size.x * 0.15 / 15) * 15 * config.plugins.bigclock.scale
  if self.font_size ~= size then
    self.time_font = renderer.font.load(DATADIR .. "/fonts/font.ttf", size)
    self.date_font = renderer.font.load(DATADIR .. "/fonts/font.ttf", size * 0.3)
    self.font_size = size
    collectgarbage()
  end
  return self.font
end


function ClockView:update()
  local time_text = os.date(config.plugins.bigclock.time_format)
  local date_text = os.date(config.plugins.bigclock.date_format)
  if self.time_text ~= time_text or self.date_text ~= date_text then
    core.redraw = true
    self.time_text = time_text
    self.date_text = date_text
  end
  ClockView.super.update(self)
end


function ClockView:draw()
  self:update_fonts()
  self:draw_background(style.background)
  local x, y = self.position.x, self.position.y
  local w, h = self.size.x, self.size.y
  local _, y = common.draw_text(self.time_font, style.text, self.time_text, "center", x, y, w, h)
  local th = self.date_font:get_height()
  common.draw_text(self.date_font, style.dim, self.date_text, "center", x, y, w, th)
end


command.add(nil, {
  ["big-clock:open"] = function()
    local node = core.root_view:get_active_node()
    node:add_view(ClockView())
  end,
})


return ClockView
