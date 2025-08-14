-- mod-version:3
-- Selection length plugin
-- Shows the selection length on statusbar
local core = require "core"
local StatusView = require "core.statusview"
local CommandView = require "core.commandview"
local DocView = require "core.docview"

local cache = setmetatable({}, { __mode = "k" })
local function get_selection_size(doc, line1, col1, line2, col2)
	-- The selection cache gets invalidated when the document changes
	local change_id = doc:get_change_id()
	if not cache[doc] or cache[doc].id ~= change_id then
		cache[doc] = { id = change_id, selections = {} }
	end

	local sel_cache = cache[doc].selections
	local selection_name = string.format("%d:%d-%d:%d", line1, col1, line2, col2)
	if not sel_cache[selection_name] then
		local total_len = 0
		-- Calculate selection length by going through selected line/lines
		for i = line1, line2 do
			local len
			if line1 == line2 then
				len = col2 - col1
			else
				if i == line1 then
					len = #doc.lines[i] - col1
				elseif i == line2 then
					len = col2
				else
					len = #doc.lines[i]
				end
			end
			total_len = total_len + len
		end
		sel_cache[selection_name] = total_len
	end

	return sel_cache[selection_name]
end

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
		for _, line1, col1, line2, col2 in dv.doc:get_selections(true) do
			if line1 ~= line2 or col1 ~= col2 then
				selection_length = selection_length + get_selection_size(dv.doc, line1, col1, line2, col2)
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
