-- mod-version:3
local core = require "core"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"
local Highlighter = require "core.doc.highlighter"
local Object = require "core.object"
local Scrollbar = require "core.scrollbar"

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
      description = "Background color of selected text.",
      path = "selection_color",
      type = "color",
      default = string.format("#%02X%02X%02X%02X",
        style.dim[1], style.dim[2], style.dim[3], style.dim[4]
      )
    },
    {
      label = "Caret Color",
      description = "Background color of active line.",
      path = "caret_color",
      type = "color",
      default = string.format("#%02X%02X%02X%02X",
        style.caret[1], style.caret[2], style.caret[3], style.caret[4]
      )
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
local char_spacing
local char_height
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
  char_spacing = 0.8 * SCALE * config.plugins.minimap.scale
  -- keep y aligned to pixels
  char_height = math.max(1, math.floor(1 * SCALE * config.plugins.minimap.scale + 0.5))
  line_spacing = math.max(1, math.floor(2 * SCALE * config.plugins.minimap.scale + 0.5))
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


local MiniMap = Scrollbar:extend()


function MiniMap:new(dv)
  MiniMap.super.new(self, { direction = "v", alignment = "e" })
  self.dv = dv
  self.enabled = nil
end


function MiniMap:line_highlight_color(line_index)
  -- other plugins can override this, and return a color
end


function MiniMap:is_minimap_enabled()
  if self.enabled ~= nil then return self.enabled end
  if not config.plugins.minimap.enabled then return false end
  if config.plugins.minimap.avoid_small_docs then
    local last_line = #self.dv.doc.lines
    if type(config.plugins.minimap.avoid_small_docs) == "number" then
      return last_line > config.plugins.minimap.avoid_small_docs
    else
      local docview = self.dv
      local _, y = docview:get_line_screen_position(last_line, #docview.doc.lines[last_line])
      y = y + docview.scroll.y - docview.position.y + docview:get_line_height()
      return y > docview.size.y
    end
  end
  return true
end


function MiniMap:get_minimap_dimensions()
  local x, y, w, h = self:get_track_rect()
  local _, cy, _, cy2 = self.dv:get_content_bounds()
  local lh = self.dv:get_line_height()

  local visible_lines_start = math.max(1, math.floor(cy / lh))
  local visible_lines_count = math.max(1, (cy2 - cy) / lh)
  local minimap_lines_start = 1
  local minimap_lines_count = math.floor(h / line_spacing)
  local line_count = #self.dv.doc.lines

  local is_file_too_large = line_count > 1 and line_count > minimap_lines_count
  if is_file_too_large then
    local scroll_pos = (visible_lines_start - 1) /
       (line_count - visible_lines_count - 1)
    scroll_pos = math.min(1.0, scroll_pos) -- 0..1, procent of visual area scrolled

    local thumb_height = visible_lines_count * line_spacing
    local scroll_pos_pixels = scroll_pos * (h - thumb_height)

    minimap_lines_start = visible_lines_start -
        math.floor(scroll_pos_pixels / line_spacing)
    minimap_lines_start = math.max(1, minimap_lines_start)
  end
  return visible_lines_start, visible_lines_count, minimap_lines_start, minimap_lines_count, is_file_too_large
end


function MiniMap:_get_track_rect_normal()
  if not self:is_minimap_enabled() then return MiniMap.super._get_track_rect_normal(self) end
  return self.dv.size.x + self.dv.position.x - config.plugins.minimap.width, self.dv.position.y, config.plugins.minimap.width, self.dv.size.y
end


function MiniMap:get_active_margin() if self:is_minimap_enabled() then return 0 else return MiniMap.super.get_active_margin(self) end end


function MiniMap:_get_thumb_rect_normal()
  if not self:is_minimap_enabled() then return MiniMap.super._get_thumb_rect_normal(self) end
  local visible_lines_start, visible_lines_count, minimap_lines_start, minimap_lines_count, is_file_too_large = self:get_minimap_dimensions()
  local visible_y = self.dv.position.y + (visible_lines_start - 1) * line_spacing
  if is_file_too_large then
    local line_count = #self.dv.doc.lines
    local scroll_pos = (visible_lines_start - 1) /
       (line_count - visible_lines_count - 1)
    scroll_pos = math.min(1.0, scroll_pos) -- 0..1, procent of visual area scrolled

    local thumb_height = visible_lines_count * line_spacing
    local scroll_pos_pixels = scroll_pos * (self.dv.size.y - thumb_height)
    visible_y = self.dv.position.y + scroll_pos_pixels
  end
  return self.dv.size.x + self.dv.position.x - config.plugins.minimap.width, visible_y, config.plugins.minimap.width, visible_lines_count * line_spacing
end


function MiniMap:on_mouse_pressed(button, x, y, clicks)
  local percent = MiniMap.super.on_mouse_pressed(self, button, x, y, clicks)
  if not self:is_minimap_enabled() or not percent then return percent end
  local _, visible_lines_count, minimap_lines_start, minimap_lines_count, is_file_too_large = self:get_minimap_dimensions()
  local _, _, w, h = self:get_track_rect()
  local tx, ty, tw, th = self:get_thumb_rect()
  if y >= ty and y < ty + th then self.drag_start_offset = (y - ty) - th / 2 return self.percent end
  self.drag_start_offset = 0
  self.hovering.thumb = x >= tx and x < tx + tw and y >= ty and y < ty + th
  self.dragging = self.hovering.thumb
  local lh = self.dv:get_line_height()
  percent = math.max(0.0, math.min((y - self.dv.position.y) / h, 1.0))
  return (((percent * minimap_lines_count) + minimap_lines_start) * lh / self.dv:get_scrollable_size()) - (visible_lines_count / #self.dv.doc.lines / 2)
end


function MiniMap:on_mouse_moved(x, y, dx, dy)
  local percent = MiniMap.super.on_mouse_moved(self, x, y, dx, dy)
  if not self:is_minimap_enabled() or type(percent) ~= "number" then return percent end
  local _, visible_lines_count, minimap_lines_start, minimap_lines_count, is_file_too_large = self:get_minimap_dimensions()
  local lh = self.dv:get_line_height()
  local _, _, w, h = self:get_track_rect()
  local tx, ty, tw, th = self:get_thumb_rect()
  if x >= tx and x < tx + tw and y >= ty and y < ty + th then self.hovering.thumb = true end
  if not self.hovering.thumb then return self.percent end
  y = y - self.drag_start_offset
  percent = math.max(0.0, math.min((y - self.dv.position.y) / h, 1.0))
  return (((percent * minimap_lines_count) + minimap_lines_start) * lh / self.dv:get_scrollable_size()) - (visible_lines_count / #self.dv.doc.lines / 2)
end

function MiniMap:draw_thumb()
  local color = self.hovering.thumb and style.scrollbar2 or style.scrollbar
  local x, y, w, h = self:get_thumb_rect()
  renderer.draw_rect(x, y, w, h, color)
end

function MiniMap:draw()
  if not self:is_minimap_enabled() then return MiniMap.super.draw(self) end
  local dv = self.dv
  local x, y, w, h = self:get_track_rect()

  local highlight = dv.hovered_scrollbar or dv.dragging_scrollbar
  local visual_color = highlight and style.scrollbar2 or style.scrollbar

  local visible_lines_start, visible_lines_count,
    minimap_lines_start, minimap_lines_count = self:get_minimap_dimensions()

  if config.plugins.minimap.draw_background then
    renderer.draw_rect(x, y, w, h, style.minimap_background or style.background)
  end
  self:draw_thumb()

  -- highlight the selected lines, and the line with the caret on it
  local selection_color = config.plugins.minimap.selection_color or style.dim
  local caret_color = config.plugins.minimap.caret_color or style.caret

  for i, line1, col1, line2, col2 in dv.doc:get_selections() do
    local selection1_y = y + (line1 - minimap_lines_start) * line_spacing
    local selection2_y = y + (line2 - minimap_lines_start) * line_spacing
    local selection_min_y = math.min(selection1_y, selection2_y)
    local selection_h = math.abs(selection2_y - selection1_y)+1
    renderer.draw_rect(x, selection_min_y, w, selection_h, selection_color)
    renderer.draw_rect(x, selection1_y, w, line_spacing, caret_color)
  end

  local highlight_align = config.plugins.minimap.highlight_align
  local highlight_width = config.plugins.minimap.highlight_width
  local gutter_width = config.plugins.minimap.gutter_width

  -- time to draw the actual code, setup some local vars that are used in both highlighted and plain rendering.
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
    local highlight_color = self:line_highlight_color(idx)
    if highlight_color then
      renderer.draw_rect(highlight_x, line_y, highlight_width, line_spacing, highlight_color)
    end
  end

  local endidx = math.min(minimap_lines_start + minimap_lines_count, #self.dv.doc.lines)

  reset_cache_if_needed()

  if not highlighter_cache[dv.doc.highlighter] then
    highlighter_cache[dv.doc.highlighter] = {}
  end

  -- per line
  for idx = minimap_lines_start, endidx do
    batch_syntax_type = nil
    batch_start = 0
    batch_width = 0
    last_batch_end = -1

    render_highlight(idx, line_y)
    local cache = highlighter_cache[dv.doc.highlighter][idx]
    if not highlighter_cache[dv.doc.highlighter][idx] then -- need to cache
      highlighter_cache[dv.doc.highlighter][idx] = {}
      cache = highlighter_cache[dv.doc.highlighter][idx]
      -- per token
      for _, type, text in dv.doc.highlighter:each_token(idx) do
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


local old_docview_new = DocView.new
function DocView:new(doc)
  old_docview_new(self, doc)
  if self:is(DocView) then self.v_scrollbar = MiniMap(self) end
end

local old_docview_scroll_to_make_visible = DocView.scroll_to_make_visible
function DocView:scroll_to_make_visible(line, col, ...)
  if
    not self:is(DocView) or not self.v_scrollbar:is(MiniMap)
    or
    not self.v_scrollbar:is_minimap_enabled()
  then
    return old_docview_scroll_to_make_visible(self, line, col, ...)
  end
  local old_size = self.size.x
  self.size.x = math.max(0, self.size.x - config.plugins.minimap.width)
  local result = old_docview_scroll_to_make_visible(self, line, col, ...)
  self.size.x = old_size
  return result
end


local function get_all_docviews(node, t)
  t = t or {}
  if not node then return end
  if node.type == "leaf" then
    for i,v in ipairs(node.views) do
      if v:is(DocView) then
        table.insert(t, v)
      end
    end
  end
  get_all_docviews(node.a, t)
  get_all_docviews(node.b, t)
  return t
end


command.add(nil, {
  ["minimap:toggle-visibility"] = function()
    config.plugins.minimap.enabled = not config.plugins.minimap.enabled
    for i,v in ipairs(get_all_docviews(core.root_view.root_node)) do
      v.v_scrollbar.enabled = nil
    end
  end,
  ["minimap:toggle-syntax-highlighting"] = function()
    config.plugins.minimap.syntax_highlight = not config.plugins.minimap.syntax_highlight
  end
})

command.add("core.docview!", {
  ["minimap:toggle-visibility-for-current-view"] = function(dv)
    local sb = dv.v_scrollbar
    if sb.enabled ~= nil then
      sb.enabled = not sb.enabled
    else
      sb.enabled = not config.plugins.minimap.enabled
    end
  end
})

return MiniMap
