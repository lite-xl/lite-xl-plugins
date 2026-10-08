-- mod-version:3

-- Author: sylphrena@hoshiboshi.uk
--
-- Exposed options under 'config.plugins.scrollbar_selection_highlight':
-- * marker_color  (default: accent color)
-- * marker_height (default: 4)


local style   = require "core.style"
local docview = require "core.docview"
local config  = require "core.config"


-- Search cache.
local cache = setmetatable ({}, { __mode = "k" })
local function get_matching_lines (view, selected_text)
	local doc = view.doc
	if not doc or not doc.lines then
		return {}
	end

	local change_id = doc.get_change_id and doc:get_change_id () or 0
	local view_cache = cache[view]

	if view_cache
		and view_cache.text      == selected_text
		and view_cache.change_id == change_id
	then
		return view_cache.lines
	end

	local matching_lines = {}
	if #selected_text > 0 then
		for i, line_text in ipairs (doc.lines) do
			if line_text:find (selected_text, 1, true) then
				table.insert (matching_lines, i)
			end
		end
	end

	cache[view] = {
		text      = selected_text,
		change_id = change_id,
		lines     = matching_lines
	}

	return matching_lines
end


local draw_scrollbar = docview.draw_scrollbar
function docview:draw_scrollbar ()
	draw_scrollbar (self)

	local line1, col1, line2, col2 = self.doc:get_selection (true)
	if line1 ~= line2 or col1 == col2 then
		return
	end

	local selected_text = self.doc:get_text (line1, col1, line2, col2)
	if selected_text:match ("^%s+$") then
		return
	end

	local matching_lines = get_matching_lines (self, selected_text)

	local total_lines = #self.doc.lines
	if total_lines == 0 then
		return
	end

	local scrollbar_width = style.scrollbar_size
	local scrollbar_pos_x = self.position.x + self.size.x - scrollbar_width
	local scrollbar_pos_y = self.position.y
	local view_height     = self.size.y

	local line_height    = self:get_line_height ()
	local virtual_height = total_lines * line_height
	if config.scroll_past_end then
		-- +1 line visible when scrolled all the way to the bottom.
		virtual_height = virtual_height + view_height - line_height
	end

	if virtual_height <= 0 then
		return
	end

	local tick_h = config.plugins.scrollbar_selection_highlight.marker_height or 4
	local color  = config.plugins.scrollbar_selection_highlight.marker_color
		or style.accent
		or style.syntax.comment
		or style.text

	for _, line_idx in ipairs (matching_lines) do
		local offset = view_height * ((line_idx - 1) * line_height / virtual_height)
		local y      = scrollbar_pos_y + math.floor (offset)
		renderer.draw_rect (scrollbar_pos_x, y, scrollbar_width, tick_h, color)
	end
end
