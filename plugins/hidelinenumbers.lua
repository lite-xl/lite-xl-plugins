-- mod-version:2 -- lite-xl 2.0
local style = require "core.style"
local DocView = require "core.docview"

DocView.draw_line_gutter = function() end
DocView.get_gutter_width = function() return style.padding.x end
