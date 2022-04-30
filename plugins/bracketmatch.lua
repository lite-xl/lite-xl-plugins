-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local style = require "core.style"
local command = require "core.command"
local keymap = require "core.keymap"
local DocView = require "core.docview"

local bracket_maps = {
  -- [     ]    (     )    {      }
  { [91] = 93, [40] = 41, [123] = 125, direction =  1 },
  -- ]     [    )     (    }      {
  { [93] = 91, [41] = 40, [125] = 123, direction = -1 },
}

local function get_token_at(doc, line, col)
  local column = 0
  for _,type,text in doc.highlighter:each_token(line) do
    column = column + #text
    if column >= col then return type, text end
  end
end

local function get_matching_bracket(doc, line, col, line_limit, open_byte, close_byte, direction)
  local end_line = line + line_limit * direction
  local depth = 0

  while line ~= end_line do
    local byte = doc.lines[line]:byte(col)
    if byte == open_byte and get_token_at(doc, line, col) ~= "comment" then
      depth = depth + 1
    elseif byte == close_byte and get_token_at(doc, line, col) ~= "comment" then
      depth = depth - 1
      if depth == 0 then return line, col end
    end

    local prev_line, prev_col = line, col
    line, col = doc:position_offset(line, col, direction)
    if line == prev_line and col == prev_col then
      break
    end
  end
end


local state = {}
local select_adj = 0

local function update_state(line_limit)
  line_limit = line_limit or math.huge

  -- reset if we don't have a document (eg. DocView isn't focused)
  local doc = core.active_view.doc
  if not doc then
    state = {}
    return
  end

  -- early exit if nothing has changed since the last call
  local line, col = doc:get_selection()
  local change_id = doc:get_change_id()
  if  state.doc == doc and state.line == line and state.col == col
  and state.change_id == change_id and state.limit == line_limit then
    return
  end

  -- find matching bracket if we're on a bracket
  local line2, col2
  for _, map in ipairs(bracket_maps) do
    for i = 0, -1, -1 do
      local line, col = doc:position_offset(line, col, i)
      local open = doc.lines[line]:byte(col)
      local close = map[open]
      if close and get_token_at(doc, line, col) ~= "comment" then
        -- i == 0 if the cursor is on the left side of a bracket (or -1 when on right)
        select_adj = i + 1 -- if i == 0 then select_adj = 1 else select_adj = 0 end
        line2, col2 = get_matching_bracket(doc, line, col, line_limit, open, close, map.direction)
        goto found
      end
    end
  end
  ::found::

  -- update
  state = {
    change_id = change_id,
    doc = doc,
    line = line,
    col = col,
    line2 = line2,
    col2 = col2,
    limit = line_limit,
  }
end


local update = DocView.update

function DocView:update(...)
  update(self, ...)
  update_state(100)
end


local draw_line_text = DocView.draw_line_text

function DocView:draw_line_text(idx, x, y)
  draw_line_text(self, idx, x, y)

  if self.doc == state.doc and idx == state.line2 then
    local color = style.bracketmatch_color or style.syntax["function"]
    local x1 = x + self:get_col_x_offset(idx, state.col2)
    local x2 = x + self:get_col_x_offset(idx, state.col2 + 1)
    local h = math.ceil(1 * SCALE)
    renderer.draw_rect(x1, y + self:get_line_height() - h, x2 - x1, h, color)
  end
end


command.add("core.docview", {
  ["bracket-match:move-to-matching"] = function()
    update_state()
    if state.line2 then
      core.active_view.doc:set_selection(state.line2, state.col2)
    end
  end,
  ["bracket-match:select-to-matching"] = function()
    update_state()
    if state.line2 then
        core.active_view.doc:set_selection(state.line, state.col, state.line2, state.col2 + select_adj)
    end
  end,
})

keymap.add {
  ["ctrl+m"] = "bracket-match:move-to-matching",
  ["ctrl+shift+m"] = "bracket-match:select-to-matching",
}
