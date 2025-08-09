-- mod-version:3
-- Selection length plugin
-- Shows the selection length on statusbar
local core = require "core"
local StatusView = require "core.statusview"

core.status_view:add_item({
	predicate = StatusView.predicate_docview,
	name = "doc:sel_length",
	alignment = StatusView.Item.LEFT,
	get_item = function()
		local dv = core.active_view
		-- To fix crash
		-- e.g. search_ui dir selection causes crash otherwise
		if dv.doc == nil then return {} end
		local selection_length = 0
		local selection_count = 0
		-- Go through all the selections or carets in the docview
		for _, line1, col1, line2, col2 in dv.doc:get_selections() do
			local selection = dv.doc:get_text(line1, col1, line2, col2)
			selection_length = selection_length + string.len(selection)
			selection_count = selection_count + 1
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

