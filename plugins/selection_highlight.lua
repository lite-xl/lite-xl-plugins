-- mod-version:3

-- Author: sylphrena@hoshiboshi.uk
--
-- Exposed options under 'config.plugins.selection_highlight':
-- * marker_color  (default: accent color)
-- * inline_color  (default: 0x55 opacity marker_color)
-- * marker_height (default: 4)

local style   = require "core.style"
local DocView = require "core.docview"
local config  = require "core.config"

config.plugins.selection_highlight = config.plugins.selection_highlight or {}

-- Search cache.
local document_view_cache = setmetatable ({}, { __mode = "k" })
local function get_selection_search_cache (view)
	local document = view.doc
	if not document or not document.lines or not document:has_selection () then
		return nil
	end

	local sel_start_line, sel_start_col, sel_end_line, sel_end_col = document:get_selection(true)
	if sel_start_line ~= sel_end_line or sel_start_col == sel_end_col then
		return nil
	end

	local document_change_id = document.get_change_id and document:get_change_id () or 0
	local cached_view_data   = document_view_cache[view]

	if cached_view_data
		and cached_view_data.sel_start_line     == sel_start_line
		and cached_view_data.sel_start_col      == sel_start_col
		and cached_view_data.sel_end_line       == sel_end_line
		and cached_view_data.sel_end_col        == sel_end_col
		and cached_view_data.document_change_id == document_change_id
	then
		return cached_view_data.is_valid and cached_view_data or nil
	end

	-- No cache hit.
	local selection_line_text = document.lines[sel_start_line]
	if not selection_line_text then
		return nil
	end

	local selected_text = selection_line_text:sub (sel_start_col, sel_end_col - 1)
	if selected_text == "" or selected_text:match ("^%s+$") then
		document_view_cache[view] = {
			sel_start_line     = sel_start_line,
			sel_start_col      = sel_start_col,
			sel_end_line       = sel_end_line,
			sel_end_col        = sel_end_col,
			document_change_id = document_change_id,
			is_valid           = false,
		}
		return nil
	end

	local matching_line_indices = {}
	local line_matches_map      = {}

	for line_index, current_line_text in ipairs (document.lines) do
		local line_match_positions = nil
		local search_start_column = 1

		while true do
			local match_start_col, match_end_col = current_line_text:find (selected_text, search_start_column, true)
			if not match_start_col then
				break
			end

			line_match_positions = line_match_positions or {}
			table.insert (line_match_positions, { match_start_col, match_end_col })
			search_start_column = match_end_col + 1
		end

		if line_match_positions then
			table.insert (matching_line_indices, line_index)
			line_matches_map[line_index] = line_match_positions
		end
	end

	cached_view_data = {
		sel_start_line        = sel_start_line,
		sel_start_col         = sel_start_col,
		sel_end_line          = sel_end_line,
		sel_end_col           = sel_end_col,
		document_change_id    = document_change_id,
		selected_text         = selected_text,
		matching_line_indices = matching_line_indices,
		line_matches_map      = line_matches_map, -- start_col, end_col
		is_valid              = true,
	}

	document_view_cache[view] = cached_view_data
	return cached_view_data
end


local function get_marker_color ()
	return config.plugins.selection_highlight.marker_color or style.accent
end


local derived_inline_color = { 0, 0, 0, 0x55 }
local function get_inline_color ()
	if config.plugins.selection_highlight.inline_color then
		return config.plugins.selection_highlight.inline_color
	end

	local marker_color = get_marker_color ()
	if derived_inline_color[1] ~= marker_color[1]
		or derived_inline_color[2] ~= marker_color[2]
		or derived_inline_color[3] ~= marker_color[3]
	then
		derived_inline_color[1] = marker_color[1]
		derived_inline_color[2] = marker_color[2]
		derived_inline_color[3] = marker_color[3]
	end

	return derived_inline_color
end


-- Inline highlighting.
local original_draw_line_body = DocView.draw_line_body
function DocView:draw_line_body (line_index, x, y)
	local line_height = original_draw_line_body (self, line_index, x, y)

	local search_cache = get_selection_search_cache (self)
	if not search_cache then
		return line_height
	end

	local line_matches = search_cache.line_matches_map[line_index]
	if not line_matches then
		return line_height
	end

	local active_selection_line, active_selection_start_col, _, _ = self.doc:get_selection (true)

	for _, match_range in ipairs (line_matches) do
		local match_start_col, match_end_col = match_range[1], match_range[2]
		-- Skip highlighting the active selection itself.
		if line_index ~= active_selection_line or match_start_col ~= active_selection_start_col then
			local box_start_x = x + self:get_col_x_offset (line_index, match_start_col)
			local box_end_x   = x + self:get_col_x_offset (line_index, match_end_col + 1)
			renderer.draw_rect (box_start_x, y, box_end_x - box_start_x, line_height, get_inline_color ())
		end
	end

	return line_height
end


-- Scrollbar highlighting.
local original_draw_scrollbar = DocView.draw_scrollbar
function DocView:draw_scrollbar ()
	original_draw_scrollbar (self)

	local search_cache = get_selection_search_cache(self)
	if not search_cache or #search_cache.matching_line_indices == 0 then
		return
	end

	local total_document_lines = #self.doc.lines
	if total_document_lines == 0 then
		return
	end

	local scrollbar_width      = style.scrollbar_size
	local scrollbar_position_x = self.position.x + self.size.x - scrollbar_width
	local scrollbar_position_y = self.position.y
	local view_height          = self.size.y

	local line_height = self:get_line_height ()
	local virtual_height = total_document_lines * line_height
	if config.scroll_past_end then
		virtual_height = virtual_height + view_height - line_height
	end

	if virtual_height <= 0 then
		return
	end

	local marker_height = config.plugins.selection_highlight.marker_height or 4

	for _, line_index in ipairs (search_cache.matching_line_indices) do
		local vertical_offset   = view_height * ((line_index - 1) * line_height / virtual_height)
		local marker_position_y = scrollbar_position_y + math.floor (vertical_offset)
		renderer.draw_rect (scrollbar_position_x, marker_position_y, scrollbar_width, marker_height, get_marker_color ())
	end
end
