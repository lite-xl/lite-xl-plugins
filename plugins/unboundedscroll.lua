-- mod-version:3 --lite-xl 2.1
local command = require "core.command"
local DocView = require "core.docview"

local doc_view_clamp_scroll_position = DocView.clamp_scroll_position
local function clamp_scroll_noop() end

DocView.clamp_scroll_position = clamp_scroll_noop

command.add(nil, {
  ["unbounded-scroll:toggle"] = function()
    if DocView.clamp_scroll_position == clamp_scroll_noop then
      DocView.clamp_scroll_position = doc_view_clamp_scroll_position
    else
      DocView.clamp_scroll_position = clamp_scroll_noop
    end
  end,
})
