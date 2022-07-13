-- mod-version:3
local core = require "core"
local config = require "core.config"
local common = require "core.common"
local style = require "core.style"
local StatusView = require "core.statusview"

config.plugins.smallclock = common.merge({
  enabled = true,
  clock_type = "24",
	-- The config specification used by the settings gui
  config_spec = {
    name = "Small Clock",
    {
      label = "Enabled",
      description = "Show or hide the small clock from the status bar.",
      path = "enabled",
      type = "toggle",
      default = true,
      on_apply = function(enabled)
        core.add_thread(function()
          if enabled then
            core.status_view:get_item("status:small-clock"):show()
          else
            core.status_view:get_item("status:small-clock"):hide()
          end
        end)
      end
    },
    {
      label = "Clock Type",
      description = "Choose between 12 or 24 hours clock mode.",
      path = "clock_type",
      type = "selection",
      default = "24",
      values = {
        {"24 Hours", "24"},
        {"12 Hours", "12"}
      }
    }
  }
}, config.plugins.smallclock)

local time = ""

local last_time = os.time()
local function update_time()
  if os.time() > last_time then
    local h = config.plugins.smallclock.clock_type == "24"
      and os.date("%H") or os.date("%I")
    local m = os.date("%M")
    time = string.format("%02d:%02d", h, m)
    last_time = os.time()
  end
end

core.status_view:add_item({
  name = "status:small-clock",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    update_time()
    return {style.accent, time}
  end,
  position = -1,
  separator = core.status_view.separator2
})
