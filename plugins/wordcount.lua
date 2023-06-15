-- mod-version:3
local core = require "core"
local style = require "core.style"
local StatusView = require "core.statusview"
local CommandView = require "core.commandview"
local DocView = require "core.docview"
local Doc = require "core.doc"
local keymap = require "core.keymap"


local words = setmetatable({}, { __mode = "k" })


local function compute_line_words(line)
  local s, total_words = 1, 0
  while true do
    local ns, e = line:find("%s+", s)
    if ns == 1 and e == #line then break end
    if not e then total_words = math.max(total_words, 1) break end
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

local cached_word_length, cached_word_count

core.status_view:add_item({
  predicate = function() return core.active_view:is(DocView) and not core.active_view:is(CommandView) and words[core.active_view.doc] end,
  name = "status:word-count",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    local selection_text = core.active_view.doc:get_selection_text()
    if #selection_text ~= cached_word_length then
      cached_word_count = compute_line_words(selection_text)
      cached_word_length = #selection_text
    end
    if #selection_text > 0 then
      return { style.text, cached_word_count .. " words" }
    else
      return { style.text, words[core.active_view.doc] .. " words" }
    end
  end
})
