-- mod-version:3
local core = require "core"
local config = require "core.config"
local style = require "core.style"
local common = require "core.common"
local StatusView = require "core.statusview"

config.plugins.statusclock = common.merge({
  enabled = true,
  time_format = "%H:%M:%S",
  date_format = "%A, %d %B %Y",
  -- The config specification used by the settings gui
  config_spec = {
    name = "Status Clock",
    {
      label = "Enabled",
      description = "Show or hide the clock from the status bar.",
      path = "enabled",
      type = "toggle",
      default = true,
      on_apply = function(enabled)
        core.add_thread(function()
          if enabled then
            core.status_view:get_item("status:clock"):show()
          else
            core.status_view:get_item("status:clock"):hide()
          end
        end)
      end
    },
    {
      label = "Time Format",
      description = "Time specification defined with Lua date/time place holders.",
      path = "time_format",
      type = "string",
      default = "%H:%M:%S"
    },
    {
      label = "Date Format",
      description = "Date specification defined with Lua date/time place holders.",
      path = "date_format",
      type = "string",
      default = "%A, %d %B %Y",
    }
  }
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

core.status_view:add_item({
  name = "status:clock",
  alignment = StatusView.Item.RIGHT,
  get_item = function(self)
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
  position = -1,
  separator = core.status_view.separator2
})

