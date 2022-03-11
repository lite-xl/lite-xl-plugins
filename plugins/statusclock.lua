-- mod-version:3 --lite-xl 2.1
local core = require "core"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local StatusView = require "core.statusview"

config.plugins.statusclock = common.merge({
  time_format = "%H:%M:%S",
  date_format = "%A, %d %B %Y"
}, config.plugins.statusclock)

local time_data = {
  time_text = '',
  date_text = '',
}

local last_time = os.time()
local function update_time()
  if os.time() > last_time then
    local time_text = os.date(config.plugins.statusclock.time_format)
    local date_text = os.date(config.plugins.statusclock.date_format)

    if time_data.time_text ~= time_text or time_data.time_text ~= date_text then
      time_data.time_text = time_text
      time_data.date_text = date_text
    end
    -- only redraw if seconds enabled
    if config.plugins.statusclock.time_format:find("%S", 1, true) then
      core.redraw = true
    end
    last_time = os.time()
  end
end

core.status_view:add_item(
  nil,
  "status:clock",
  StatusView.Item.RIGHT,
  function(self)
    update_time()
    return {
      style.text,
      time_data.date_text,
      style.dim,
      self.separator,
      style.text,
      time_data.time_text,
    }
  end,
  nil,
  -1
).separator = core.status_view.separator2

