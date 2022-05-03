-- mod-version:3 --lite-xl 2.1
local core = require "core"
local style = require "core.style"
local StatusView = require "core.statusview"
local CommandView = require "core.commandview"
local DocView = require "core.docview"
local Doc = require "core.doc"
local keymap = require "core.keymap"


local words = {}


local function compute_line_words(line)
  local s, total_words = 1, 0
  while true do 
    local ns, e = line:find("%s+", s)
    if ns == 1 and e == #line then break end
    if not e then break end
    total_words = total_words + 1
    s = e + 1
  end
  return total_words
end


local function compute_words(doc, start_line, end_line)
  local total_words = 0
  for i = start_line or 1, end_line or #doc.lines do
    total_words = total_words + compute_line_words(doc.lines[i])
  end
  return total_words
end 


local old_raw_insert = Doc.raw_insert
function Doc:raw_insert(line, col, text, undo_stack, time)
  if words[self] then
    local old_count = compute_words(self, line, line)
    old_raw_insert(self, line, col, text, undo_stack, time)
    local total_lines, s = 0, 0
    while true do
      s = text:find("\n", s + 1, true)
      if not s then break end
      total_lines = total_lines + 1
    end
    print(line, line+total_lines)
    words[self] = words[self] + compute_words(self, line, line + total_lines) - old_count
  else
    old_raw_insert(self, line, col, text, undo_stack, time)
  end
end


local old_raw_remove = Doc.raw_remove
function Doc:raw_remove(line1, col1, line2, col2, undo_stack, time)
  if words[self] then
    local old_count = compute_words(self, line1, line2)
    old_raw_remove(self, line1, col1, line2, col2, undo_stack, time)
    words[self] = words[self] + compute_words(self, line1, line1) - old_count
  else
    old_raw_remove(self, line1, col1, line2, col2, undo_stack, time)
  end
end


local old_doc_new = Doc.new
function Doc:new(...)
  old_doc_new(self, ...)
  words[self] = compute_words(self)
end


core.status_view:add_item(
  function() return core.active_view:is(DocView) and not core.active_view:is(CommandView) and words[core.active_view.doc] end,
  "status:word-count",
  StatusView.Item.RIGHT,
  function()
    return { style.text, words[core.active_view.doc] .. " words" }
  end
)
