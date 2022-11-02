-- mod-version:3
local core = require "core"
local translate = require "core.doc.translate"
local config = require "core.config"
local common = require "core.common"
local DocView = require "core.docview"
local command = require "core.command"
local keymap = require "core.keymap"


config.plugins.autoinsert = common.merge({ map = {
  ["["] = "]",
  ["{"] = "}",
  ["("] = ")",
  ['"'] = '"',
  ["'"] = "'",
  ["`"] = "`",
} }, config.plugins.autoinsert)


-- Workaround for bug in Lite XL 2.1
-- Remove this when b029f5993edb7dee5ccd2ba55faac1ec22e24609 is in a release
local function get_selection(doc, sort)
  local line1, col1, line2, col2 = doc:get_selection_idx(doc.last_selection)
  if line1 then
    return doc:get_selection_idx(doc.last_selection, sort)
  else
    return doc:get_selection_idx(1, sort)
  end
end


local function is_closer(chr)
  for _, v in pairs(config.plugins.autoinsert.map) do
    if v == chr then
      return true
    end
  end
end

local function count_char(text, chr)
  local count = 0
  for _ in text:gmatch(chr) do
    count = count + 1
  end
  return count
end


local on_text_input = DocView.on_text_input

function DocView:on_text_input(text)
  local mapping = config.plugins.autoinsert.map[text]

  -- prevents plugin from operating on `CommandView`
  if getmetatable(self) ~= DocView then
    return on_text_input(self, text)
  end

  -- wrap selection if we have a selection
  if mapping and self.doc:has_selection() then
    local l1, c1, l2, c2, swap = get_selection(self.doc, true)
    self.doc:insert(l2, c2, mapping)
    self.doc:insert(l1, c1, text)
    self.doc:set_selection(l1, c1, l2, c2 + 2, swap)
    return
  end

  -- skip inserting closing text
  local chr = self.doc:get_char(self.doc:get_selection())
  if text == chr and is_closer(chr) then
    self.doc:move_to(1)
    return
  end

  -- don't insert closing quote if we have a non-even number on this line
  local line = self.doc:get_selection()
  if text == mapping and count_char(self.doc.lines[line], text) % 2 == 1 then
    return on_text_input(self, text)
  end

  -- auto insert closing bracket
  if mapping and (chr:find("%s") or is_closer(chr) and chr ~= '"') then
    on_text_input(self, text)
    on_text_input(self, mapping)
    self.doc:move_to(-1)
    return
  end

  on_text_input(self, text)
end



local function predicate()
  return core.active_view:is(DocView)
     and not core.active_view.doc:has_selection(), core.active_view.doc
end

command.add(predicate, {
  ["autoinsert:backspace"] = function(doc)
    local l, c = doc:get_selection()
    if c > 1 then
      local chr = doc:get_char(l, c)
      local mapped = config.plugins.autoinsert.map[doc:get_char(l, c - 1)]
      if mapped and mapped == chr then
        doc:delete_to(1)
      end
    end
    command.perform "doc:backspace"
  end,

  ["autoinsert:delete-to-previous-word-start"] = function(doc)
    local le, ce = translate.previous_word_start(doc, doc:get_selection())
    while true do
      local l, c = doc:get_selection()
      if l == le and c == ce then
        break
      end
      command.perform "autoinsert:backspace"
    end
  end,
})

keymap.add {
  ["backspace"]            = "autoinsert:backspace",
  ["ctrl+backspace"]       = "autoinsert:delete-to-previous-word-start",
  ["ctrl+shift+backspace"] = "autoinsert:delete-to-previous-word-start",
}
