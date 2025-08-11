-- mod-version:3
-- Selection length plugin
-- Shows the selection length on statusbar
local core = require "core"
local StatusView = require "core.statusview"
local CommandView = require "core.commandview"
local DocView = require "core.docview"

core.status_view:add_item({
	predicate = function()
		return core.active_view:is(DocView)
			and not core.active_view:is(CommandView)
	end,
	name = "status:sel_length",
	alignment = StatusView.Item.LEFT,
	get_item = function()
		local dv = core.active_view
		local selection_count = #dv.doc.selections/4
		local selection_length = 0
		-- Go through all the selections or carets in the docview
		for _, line1, col1, line2, col2 in dv.doc:get_selections() do
			if line1 ~= line2 or col1 ~= col2 then
				local selection = dv.doc:get_text(line1, col1, line2, col2)
				selection_length = selection_length + string.len(selection)
			end
		end

		-- If selection length is zero, don't bother showing any status
		if selection_length == 0 then return {} end

		-- Indicate if showing selection length for 1 selection, or more
		local status_prefix = (selection_count <= 1 and "sel: " or "sels: ")

		-- Show selection length in status
		return {
			status_prefix, selection_length,
		}
	end,
	position = -1,
	tooltip = "selection length",
	separator = core.status_view.separator2
})

