-- mod-version:3

local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"

config.plugins.typingspeed = common.merge({
  enabled = true,
	-- characters that should be counted as word boundary
	word_boundaries = "[%p%s]",
	-- The config specification used by the settings gui
  config_spec = {
    name = "Typing Speed",
    {
      label = "Enabled",
      description = "Show or hide the typing speed from the status bar.",
      path = "enabled",
      type = "toggle",
      default = true,
      on_apply = function(enabled)
        core.add_thread(function()
          if enabled then
            core.status_view:get_item("typing-speed:stats"):show()
          else
            core.status_view:get_item("typing-speed:stats"):hide()
          end
        end)
      end
    },
    {
      label = "Word Boundaries",
      description = "Lua pattern that matches characters to separate words.",
      path = "word_boundaries",
      type = "string",
      default = "[%p%s]"
    }
  }
}, config.plugins.typingspeed)

local chars = 0
local chars_last = 0
local words = 0
local words_last = 0
local time_last = 0
local started_word = false
local cpm = 0
local wpm = 0

core.add_thread(function()
	while true do
    if config.plugins.typingspeed.enabled then
      local t = os.date("*t")
      if t.sec <= time_last then
        words_last = words
        words = 0
        chars_last = chars
        chars = 0
        time_last = t.sec
      end
      wpm = words_last * (1-(t.sec)/60) + words
      cpm = chars_last * (1-(t.sec)/60) + chars
    end
		coroutine.yield(1)
	end
end)

local on_text_input = DocView.on_text_input
function DocView:on_text_input(text, idx)
  if config.plugins.typingspeed.enabled then
    chars = chars + 1
    if string.find(text, config.plugins.typingspeed.word_boundaries) then
      if started_word then
        words = words + 1
        started_word = false
      end
    else
      started_word = true
    end
  end
	on_text_input(self, text, idx)
end

core.status_view:add_item({
  predicate = function()
    return core.active_view and getmetatable(core.active_view) == DocView
  end,
  name = "typing-speed:stats",
  alignment = core.status_view.Item.RIGHT,
  get_item = function()
    return {
      style.text,
      string.format("%.0f CPM / %.0f WPM", cpm, wpm)
    }
  end,
  position = 1,
  tooltip = "characters / words per minute",
  separator = core.status_view.separator2
})
