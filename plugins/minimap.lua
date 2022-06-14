-- mod-version:3
local core = require "core"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"
local Highlighter = require "core.doc.highlighter"
local Object = require "core.object"

-- Sample configurations:
-- full width:
-- config.plugins.minimap.highlight_width = 100
-- config.plugins.minimap.gutter_width = 0
-- left side:
-- config.plugins.minimap.highlight_align = 'left'
-- config.plugins.minimap.highlight_width = 3
-- config.plugins.minimap.gutter_width = 4
-- right side:
-- config.plugins.minimap.highlight_align = 'right'
-- config.plugins.minimap.highlight_width = 5
-- config.plugins.minimap.gutter_width = 0

-- General plugin settings
config.plugins.minimap = common.merge({
  enabled = true,
  width = 100,
  instant_scroll = false,
  syntax_highlight = true,
  scale = 1,
  -- number of spaces needed to split a token
  spaces_to_split = 2,
  -- hide on small docs (can be true, false or min number of lines)
  avoid_small_docs = false,
  -- how many spaces one tab is equivalent to
  tab_width = 4,
  draw_background = true,
  -- you can override these colors
  selection_color = nil,
  caret_color = nil,
  -- If other plugins provide per-line highlights,
  -- this controls the placement. (e.g. gitdiff_highlight)
  highlight_align = 'left',
  highlight_width = 3,
  gutter_width = 5,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Mini Map",
    {
      label = "Enabled",
      description = "Activate the minimap by default.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Width",
      description = "Width of the minimap in pixels.",
      path = "width",
      type = "number",
      default = 100,
      min = 50,
      max = 1000
    },
    {
      label = "Instant Scroll",
      description = "When enabled disables the scrolling animation.",
      path = "instant_scroll",
      type = "toggle",
      default = false
    },
    {
      label = "Syntax Highlighting",
      description = "Disable to improve performance.",
      path = "syntax_highlight",
      type = "toggle",
      default = true
    },
    {
      label = "Scale",
      description = "Size of the minimap using a scaling factor.",
      path = "scale",
      type = "number",
      default = 1,
      min = 0.5,
      max = 10,
      step = 0.1
    },
    {
      label = "Spaces to split",
      description = "Number of spaces needed to split a token.",
      path = "spaces_to_split",
      type = "number",
      default = 2,
      min = 1
    },
    {
      label = "Hide for small Docs",
      description = "Hide the minimap when a Doc is small enough.",
      path = "avoid_small_docs",
      type = "toggle",
      default = false
    },
    {
      label = "Small Docs definition",
      description = "Size of a Doc to be considered small. Use 0 to automatically decide.",
      path = "avoid_small_docs_len",
      type = "number",
      default = 0,
      min = 0,
      on_apply = function(value)
        if value == 0 then
          config.plugins.minimap.avoid_small_docs = true
        else
          config.plugins.minimap.avoid_small_docs = value
        end
      end
    },
    {
      label = "Tabs Width",
      description = "The amount of spaces that represent a tab.",
      path = "tab_width",
      type = "number",
      default = 4,
      min = 1,
      max = 8
    },
    {
      label = "Draw Background",
      description = "When disabled makes the minimap transparent.",
      path = "draw_background",
      type = "toggle",
      default = true
    },
    {
      label = "Selection Color",
      description = "Background color of selected text in html notation eg: #FFFFFF. Leave empty to use default.",
      path = "selection_color_html",
      type = "string",
      on_apply = function(value)
        if value and value:match("#%x%x%x%x%x%x") then
          config.plugins.minimap.selection_color = { common.color(value) }
        else
          config.plugins.minimap.selection_color = nil
        end
      end
    },
    {
      label = "Caret Color",
      description = "Background color of active line in html notation eg: #FFFFFF. Leave empty to use default.",
      path = "caret_color_html",
      type = "string",
      on_apply = function(value)
        if value and value:match("#%x%x%x%x%x%x") then
          config.plugins.minimap.caret_color = { common.color(value) }
        else
          config.plugins.minimap.caret_color = nil
        end
      end
    },
    {
      label = "Highlight Alignment",
      path = "highlight_align",
      type = "selection",
      default = "left",
      values = {
        {"Left", "left"},
        {"Right", "right"}
      }
    },
    {
      label = "Highlight Width",
      path = "highlight_width",
      type = "number",
      default = 3,
      min = 0,
      max = 50
    },
    {
      label = "Gutter Width",
      description = "Left padding of the minimap.",
      path = "gutter_width",
      type = "number",
      default = 5,
      min = 0,
      max = 50
    },
  }
}, config.plugins.minimap)


-- contains the settings values that require a cache reset if changed
local cached_settings = {
  color_scheme_canary = nil,
  syntax_highlight = nil,
  spaces_to_split = nil,
  scale = nil,
  width = nil,
}

-- Configure size for rendering each char in the minimap
local char_height
local char_spacing
local line_spacing

-- cache for the location of the rects for each Doc
local highlighter_cache
local function reset_cache()
  highlighter_cache = setmetatable({}, { __mode = "k" })
  cached_settings = {
    color_scheme_canary = style.syntax["normal"],
    syntax_highlight = config.plugins.minimap.syntax_highlight,
    spaces_to_split = config.plugins.minimap.spaces_to_split,
    scale = config.plugins.minimap.scale,
    width = config.plugins.minimap.width,
  }
  char_height = 1 * SCALE * config.plugins.minimap.scale
  char_spacing = 0.8 * SCALE * config.plugins.minimap.scale
  line_spacing = 2 * SCALE * config.plugins.minimap.scale
end
reset_cache()


local function reset_cache_if_needed()
  if
    cached_settings.color_scheme_canary ~= style.syntax["normal"]
    or cached_settings.syntax_highlight ~= config.plugins.minimap.syntax_highlight
    or cached_settings.spaces_to_split  ~= config.plugins.minimap.spaces_to_split
    or cached_settings.scale            ~= config.plugins.minimap.scale
    or cached_settings.width            ~= config.plugins.minimap.width
  then
    reset_cache()
  end
end


-- minimap status per DocView
local per_docview
local function reset_per_docview()
  per_docview = setmetatable({}, { __mode = "k" })
end
reset_per_docview()


-- Move cache to make space for new lines
local prev_insert_notify = Highlighter.insert_notify
function Highlighter:insert_notify(line, n, ...)
  prev_insert_notify(self, line, n, ...)
  local blanks = { }
  if not highlighter_cache[self] then
    highlighter_cache[self] = {}
  else
    local to = math.min(line + n, #self.doc.lines)
    for i=#self.doc.lines+n,to,-1 do
      highlighter_cache[self][i] = highlighter_cache[self][i - n]
    end
    for i=line,to do
      highlighter_cache[self][i] = nil
    end
  end
end


-- Close the cache gap created by removed lines
local prev_remove_notify = Highlighter.remove_notify
function Highlighter:remove_notify(line, n, ...)
  prev_remove_notify(self, line, n, ...)
  if not highlighter_cache[self] then
    highlighter_cache[self] = {}
  else
    local to = math.max(line + n, #self.doc.lines)
    for i=line,to do
      highlighter_cache[self][i] = highlighter_cache[self][i + n]
    end
  end
end


-- Remove changed lines from the cache
local prev_tokenize_line = Highlighter.tokenize_line
function Highlighter:tokenize_line(idx, state, ...)
  local res = prev_tokenize_line(self, idx, state, ...)
  if not highlighter_cache[self] then
    highlighter_cache[self] = {}
  end
  highlighter_cache[self][idx] = nil
  return res
end

-- Ask the Highlighter to retokenize the lines we have in cache
local prev_invalidate = Highlighter.invalidate
function Highlighter:invalidate(idx, ...)
  local cache = highlighter_cache[self]
  if cache then
    self.max_wanted_line = math.max(self.max_wanted_line, #cache)
  end
  return prev_invalidate(self, idx, ...)
end


-- Remove cache on Highlighter reset (for example on syntax change)
local prev_soft_reset = Highlighter.soft_reset
function Highlighter:soft_reset(...)
  prev_soft_reset(self, ...)
  highlighter_cache[self] = {}
end


local MiniMap = Object:extend()

function MiniMap:new()
end

function MiniMap:line_highlight_color(line_index)
  -- other plugins can override this, and return a color
end

local minimap = MiniMap()

local function show_minimap(docview)
  if not docview:is(DocView) then return false end
  if
    not config.plugins.minimap.enabled
    and per_docview[docview] ~= true
  then
    return false
  elseif
    config.plugins.minimap.enabled
    and per_docview[docview] == false
  then
    return false
  end
  if config.plugins.minimap.avoid_small_docs then
    local last_line = #docview.doc.lines
    if type(config.plugins.minimap.avoid_small_docs) == "number" then
      return last_line > config.plugins.minimap.avoid_small_docs
    else
      local _, y = docview:get_line_screen_position(last_line, docview.doc.lines[last_line])
      y = y + docview.scroll.y - docview.position.y + docview:get_line_height()
      return y > docview.size.y
    end
  end
  return true
end

-- Overloaded since the default implementation adds a extra x3 size of hotspot for the mouse to hit the scrollbar.
local prev_scrollbar_overlaps_point = DocView.scrollbar_overlaps_point
DocView.scrollbar_overlaps_point = function(self, x, y)
  if not show_minimap(self) then
    return prev_scrollbar_overlaps_point(self, x, y)
  end

  local sx, sy, sw, sh = self:get_scrollbar_rect()
  return x >= sx and x < sx + sw and y >= sy and y < sy + sh
end

-- Helper function to determine if current file is too large to be shown fully inside the minimap area.
local function is_file_too_large(self)
  local line_count = #self.doc.lines
  local _, _, _, sh = self:get_scrollbar_rect()

  -- check if line count is too large to fit inside the minimap area
  local max_minmap_lines = math.floor(sh / line_spacing)
  return line_count > 1 and line_count > max_minmap_lines
end

-- Overloaded with an extra check if the user clicked inside the minimap to automatically scroll to that line.
local prev_on_mouse_pressed = DocView.on_mouse_pressed
DocView.on_mouse_pressed = function(self, button, x, y, clicks)
  if not show_minimap(self) then
    return prev_on_mouse_pressed(self, button, x, y, clicks)
  end

  -- check if user clicked in the minimap area and jump directly to that line
  -- unless they are actually trying to perform a drag
  local minimap_hit = self:scrollbar_overlaps_point(x, y)
  if minimap_hit then
    local line_count = #self.doc.lines
    local minimap_height = line_count * line_spacing

    -- check if line count is too large to fit inside the minimap area
    local is_too_large = is_file_too_large(self)
    if is_too_large then
      local _, _, _, sh = self:get_scrollbar_rect()
      minimap_height = sh
    end

    -- calc which line to jump to
    local dy = y - self.position.y
    local jump_to_line = math.floor((dy / minimap_height) * line_count) + 1

    local _, cy, _, cy2 = self:get_content_bounds()
    local lh = self:get_line_height()
    local visible_lines_count = math.max(1, (cy2 - cy) / lh)
    local visible_lines_start = math.max(1, math.floor(cy / lh))

    -- calc if user hit the currently visible area
    local hit_visible_area = true
    if is_too_large then

      local visible_height = visible_lines_count * line_spacing
      local scroll_pos = (visible_lines_start - 1) /
                                 (line_count - visible_lines_count - 1)
      scroll_pos = math.min(1.0, scroll_pos) -- 0..1
      local visible_y = self.position.y + scroll_pos *
                                (minimap_height - visible_height)

      local t = (line_count - visible_lines_start) / visible_lines_count
      if t <= 1 then visible_y = visible_y + visible_height * (1.0 - t) end

      if y < visible_y or y > visible_y + visible_height then
        hit_visible_area = false
      end
    else

      -- If the click is on the currently visible line numbers,
      -- ignore it since then they probably want to initiate a drag instead.
      if jump_to_line < visible_lines_start or jump_to_line > visible_lines_start +
              visible_lines_count then hit_visible_area = false end
    end

    -- if user didn't click on the visible area (ie not dragging), scroll accordingly
    if not hit_visible_area then
      self:scroll_to_line(jump_to_line, false, config.plugins.minimap.instant_scroll)
    end

  end

  return prev_on_mouse_pressed(self, button, x, y, clicks)
end

-- Overloaded with pretty much the same logic as original DocView implementation,
-- with the exception of the dragging scrollbar delta. We want it to behave a bit snappier
-- since the "scrollbar" essentially represents the lines visible in the content view.
local prev_on_mouse_moved = DocView.on_mouse_moved
DocView.on_mouse_moved = function(self, x, y, dx, dy)
  if not show_minimap(self) then
    return prev_on_mouse_moved(self, x, y, dx, dy)
  end

  if self.dragging_scrollbar then
    local line_count = #self.doc.lines
    local lh = self:get_line_height()
    local delta = lh / line_spacing * dy

    if is_file_too_large(self) then
      local _, sy, _, sh = self:get_scrollbar_rect()
      delta = (line_count * lh) / sh * dy
    end

    self.scroll.to.y = self.scroll.to.y + delta
  end

  -- we need to "hide" that the scrollbar is dragging so that View doesnt does its own scrolling logic
  local t = self.dragging_scrollbar
  self.dragging_scrollbar = false
  local r = prev_on_mouse_moved(self, x, y, dx, dy)
  self.dragging_scrollbar = t
  return r
end

-- Overloaded since we want the mouse to interact with the full size of the minimap area,
-- not juse the scrollbar.
local prev_get_scrollbar_rect = DocView.get_scrollbar_rect
DocView.get_scrollbar_rect = function(self)
  if not show_minimap(self) then return prev_get_scrollbar_rect(self) end

  return self.position.x + self.size.x - config.plugins.minimap.width * SCALE,
         self.position.y, config.plugins.minimap.width * SCALE, self.size.y
end

local prev_get_scrollbar_track_rect = DocView.get_scrollbar_track_rect
DocView.get_scrollbar_track_rect = function(self)
  if not show_minimap(self) then return prev_get_scrollbar_track_rect(self) end

  return self.position.x + self.size.x - config.plugins.minimap.width * SCALE,
         self.position.y, config.plugins.minimap.width * SCALE, self.size.y
end

-- Overloaded so we can render the minimap in the "scrollbar area".
local prev_draw_scrollbar = DocView.draw_scrollbar
DocView.draw_scrollbar = function(self)
  if not show_minimap(self) then return prev_draw_scrollbar(self) end

  local x, y, w, h = self:get_scrollbar_rect()

  local highlight = self.hovered_scrollbar or self.dragging_scrollbar
  local visual_color = highlight and style.scrollbar2 or style.scrollbar

  local _, cy, _, cy2 = self:get_content_bounds()
  local lh = self:get_line_height()
  local visible_lines_count = math.max(1, (cy2 - cy) / lh)
  local visible_lines_start = math.max(1, math.floor(cy / lh))
  local scroller_height = visible_lines_count * line_spacing
  local line_count = #self.doc.lines

  local visible_y = self.position.y + (visible_lines_start - 1) * line_spacing

  -- check if file is too large to fit inside the minimap area
  local max_minmap_lines = math.floor(h / line_spacing)
  local minimap_start_line = 1
  if is_file_too_large(self) then

    local scroll_pos = (visible_lines_start - 1) /
                               (line_count - visible_lines_count - 1)
    scroll_pos = math.min(1.0, scroll_pos) -- 0..1, procent of visual area scrolled

    local scroll_pos_pixels = scroll_pos * (h - scroller_height)
    visible_y = self.position.y + scroll_pos_pixels

    -- offset visible area if user is scrolling past end
    local t = (line_count - visible_lines_start) / visible_lines_count
    if t <= 1 then visible_y = visible_y + scroller_height * (1.0 - t) end

    minimap_start_line = visible_lines_start -
                                 math.floor(scroll_pos_pixels / line_spacing)
    minimap_start_line = math.max(1, math.min(minimap_start_line,
                                              line_count - max_minmap_lines))
  end

  if config.plugins.minimap.draw_background then
    renderer.draw_rect(x, y, w, h, style.minimap_background or style.background)
  end
  -- draw visual rect
  renderer.draw_rect(x, visible_y, w, scroller_height, visual_color)

  -- highlight the selected lines, and the line with the caret on it
  local selection_color = config.plugins.minimap.selection_color or style.dim
  local caret_color = config.plugins.minimap.caret_color or style.caret
  local selection_line, selection_col, selection_line2, selection_col2 = self.doc:get_selection()
  local selection_y = y + (selection_line - minimap_start_line) * line_spacing
  local selection2_y = y + (selection_line2 - minimap_start_line) * line_spacing
  local selection_min_y = math.min(selection_y, selection2_y)
  local selection_h = math.abs(selection2_y - selection_y)+1
  renderer.draw_rect(x, selection_min_y, w, selection_h, selection_color)
  renderer.draw_rect(x, selection_y, w, line_spacing, caret_color)

  local highlight_align = config.plugins.minimap.highlight_align
  local highlight_width = config.plugins.minimap.highlight_width
  local gutter_width = config.plugins.minimap.gutter_width

  -- time to draw the actual code, setup some local vars that are used in both highlighted and plain renderind.
  local line_y = y

  -- when not using syntax highlighted rendering, just use the normal color but dim it 50%.
  local color = style.syntax["normal"]
  color = {color[1], color[2], color[3], color[4] * 0.5}

  -- we try to "batch" characters so that they can be rendered as just one rectangle instead of one for each.
  local batch_width = 0
  local batch_start = x
  local last_batch_end = -1
  local minimap_cutoff_x = config.plugins.minimap.width * SCALE
  local batch_syntax_type = nil
  local function flush_batch(type, cache)
    if batch_width > 0 then
      local lastidx = #cache
      local old_color = color
      color = style.syntax[type]
      if config.plugins.minimap.syntax_highlight and color ~= nil then
        -- fetch and dim colors
        color = {color[1], color[2], color[3], (color[4] or 255) * 0.5}
      else
        color = old_color
      end
      if #cache >= 3 then
        local last_color = cache[lastidx]
        if
          last_batch_end == batch_start -- no space skipped
          and (
                batch_syntax_type == type -- and same syntax
                or (                      -- or same color
                      last_color[1] == color[1]
                      and last_color[2] == color[2]
                      and last_color[3] == color[3]
                      and last_color[4] == color[4]
                   )
              )
        then
          batch_start = cache[lastidx - 2]
          batch_width = cache[lastidx - 1] + batch_width
          lastidx = lastidx - 3
        end
      end
      cache[lastidx + 1] = batch_start
      cache[lastidx + 2] = batch_width
      cache[lastidx + 3] = color
    end
    batch_syntax_type = type
    batch_start = batch_start + batch_width
    last_batch_end = batch_start
    batch_width = 0
  end

  local highlight_x
  if highlight_align == 'left' then
    highlight_x = x
  else
    highlight_x = x + w - highlight_width
  end
  local function render_highlight(idx, line_y)
    local highlight_color = minimap:line_highlight_color(idx)
    if highlight_color then
      renderer.draw_rect(highlight_x, line_y, highlight_width, line_spacing, highlight_color)
    end
  end

  local endidx = minimap_start_line + max_minmap_lines
  endidx = math.min(endidx, line_count)

  reset_cache_if_needed()

  if not highlighter_cache[self.doc.highlighter] then
    highlighter_cache[self.doc.highlighter] = {}
  end

  -- per line
  for idx = minimap_start_line, endidx do
    batch_syntax_type = nil
    batch_start = 0
    batch_width = 0
    last_batch_end = -1

    render_highlight(idx, line_y)
    local cache = highlighter_cache[self.doc.highlighter][idx]
    if not highlighter_cache[self.doc.highlighter][idx] then -- need to cache
      highlighter_cache[self.doc.highlighter][idx] = {}
      cache = highlighter_cache[self.doc.highlighter][idx]
      -- per token
      for _, type, text in self.doc.highlighter:each_token(idx) do
        if not config.plugins.minimap.syntax_highlight then
          type = nil
        end
        local start = 1
        while true do
          -- find text followed spaces followed by newline
          local s, e, w, eol = string.ufind(text, "[^%s]*()[ \t]*()\n?", start)
          if not s then break end
          local nchars = w - s
          start = e + 1
          batch_width = batch_width + char_spacing * nchars

          local nspaces = 0
          for i=w,e do
            local whitespace = string.sub(text, i, i)
            if whitespace == "\t" then
              nspaces = nspaces + config.plugins.minimap.tab_width
            elseif whitespace == " " then
              nspaces = nspaces + 1
            end
          end
          -- not enough spaces; consider them part of the batch
          if nspaces < config.plugins.minimap.spaces_to_split then
            batch_width = batch_width + nspaces * char_spacing
          end
          -- line has ended or no more space in the minimap;
          -- we can go to the next line
          if eol <= w or batch_start + batch_width > minimap_cutoff_x then
            if batch_width > 0 then
              flush_batch(type, cache)
            end
            break
          end
          -- enough spaces to split the batch
          if nspaces >= config.plugins.minimap.spaces_to_split then
            flush_batch(type, cache)
            batch_start = batch_start + nspaces * char_spacing
          end
        end
      end
    end
    -- draw from cache
    for i=1,#cache,3 do
      local batch_start = cache[i    ] + x + gutter_width
      local batch_width = cache[i + 1]
      local color       = cache[i + 2]
      renderer.draw_rect(batch_start, line_y, batch_width, char_height, color)
    end
    line_y = line_y + line_spacing
  end
end

local prev_update = DocView.update
DocView.update = function (self)
  if not show_minimap(self) then return prev_update(self) end
  self.size.x = self.size.x - config.plugins.minimap.width * SCALE
  return prev_update(self)
end

command.add(nil, {
  ["minimap:toggle-visibility"] = function()
    config.plugins.minimap.enabled = not config.plugins.minimap.enabled
    reset_per_docview()
  end,
  ["minimap:toggle-syntax-highlighting"] = function()
    config.plugins.minimap.syntax_highlight = not config.plugins.minimap.syntax_highlight
  end
})

command.add("core.docview!", {
  ["minimap:toggle-visibility-for-current-view"] = function()
    if config.plugins.minimap.enabled then
      per_docview[core.active_view] = per_docview[core.active_view] == false
    else
      per_docview[core.active_view] = not per_docview[core.active_view]
    end
  end
})

return minimap
