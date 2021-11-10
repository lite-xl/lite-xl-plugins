-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local config = require "core.config"
local style = require "core.style"
local StatusView = require "core.statusview"
local scan_rate = 1

config.plugins.statusclock = {
  time_format = "%H:%M:%S",
  date_format = "%A, %d %B %Y"
}

local time_data = {
  time_text = '',
  date_text = '',
}

core.add_thread(function()
  while true do
    local time_text = os.date(config.plugins.statusclock.time_format)
    local date_text = os.date(config.plugins.statusclock.date_format)
    
    if time_data.time_text ~= time_text or time_data.time_text ~= date_text then
      core.redraw = true
      time_data.time_text = time_text
      time_data.date_text = date_text
    end
    
    coroutine.yield(scan_rate)
  end
end)

local get_items = StatusView.get_items

function StatusView:get_items()
  local left, right = get_items(self)
  
  local t = {
    style.dim, 
    self.separator,
    style.dim and style.text,
    time_data.date_text,
    style.dim, 
    self.separator,
    style.dim and style.text,
    time_data.time_text,
  }
  for _, item in ipairs(t) do
    table.insert(right, item)
  end

  return left, right
end

