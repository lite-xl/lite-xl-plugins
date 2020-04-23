local core = require "core"
local style = require "core.style"
local config = require "core.config"
local command = require "core.command"
local keymap = require "core.keymap"
local DocView = require "core.docview"

local bracket_map = { ["["] = "]", ["("] = ")", ["{"] = "}" }


local state = {}

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
  if state.doc == doc and state.line == line and state.col == col
  and state.limit == line_limit then
    return
  end

  -- find matching rbracket if we have an lbracket
  local line2, col2
  local chr = doc:get_text(line, col - 1, line, col)
  local rbracket = bracket_map[chr]

  if rbracket then
    local ptn = "[%" .. chr .. "%" .. rbracket .. "]"
    local offset = col - 1
    local depth = 1

    for i = line, math.min(#doc.lines, line + line_limit) do
      while offset do
        local n = doc.lines[i]:find(ptn, offset + 1)
        if n then
          local match = doc.lines[i]:sub(n, n)
          if match == chr then
            depth = depth + 1
          elseif match == rbracket then
            depth = depth - 1
            if depth == 0 then line2, col2 = i, n end
          end
        end
        offset = n
      end
      if line2 then break end
      offset = 0
    end
  end

  -- update
  state = {
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
    local h = style.divider_size
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
})

keymap.add { ["ctrl+m"] = "bracket-match:move-to-matching" }
