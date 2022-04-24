-- mod-version:2

local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local DocView = require "core.docview"

if common["merge"] then
	config.plugins.typingspeed = common.merge({
		-- characters that should be counted as word boundary
		word_boundaries = "[%p%s]",
	}, config.plugins.keystats)
else
	config.plugins.typingspeed = {
		-- characters that should be counted as word boundary
		word_boundaries = "[%p%s]",
	}
end

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
		coroutine.yield(1)
	end
end)

local on_text_input = DocView.on_text_input
function DocView:on_text_input(text, idx)
	chars = chars + 1
	if string.find(text, config.plugins.typingspeed.word_boundaries) then
		if started_word then
			words = words + 1
			started_word = false
		end
	else
		started_word = true
	end
	on_text_input(self, text, idx)
end

if core.status_view["add_item"] then
	core.status_view:add_item(
		function()
			return core.active_view and getmetatable(core.active_view) == DocView
		end,
		"keystats:stats",
		core.status_view.Item.RIGHT,
		function()
			return {
				style.text,
				string.format("%.0f CPM / %.0f WPM", cpm, wpm)
			}
		end,
		nil,
		1,
		"characters / words per minute"
	).separator = core.status_view.separator2
else
	local get_items = core.status_view.get_items
	function core.status_view:get_items()
		local left, right = get_items(self)

		local t = {
			style.text, string.format("%.0f CPM / %.0f WPM", cpm, wpm),
			style.dim, self.separator2
		}

		for i, item in ipairs(t) do
			table.insert(right, i, item)
		end

		return left, right
	end
end
