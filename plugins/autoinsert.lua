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
    local l1, c1, l2, c2, swap = self.doc:get_selection(true)
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
  return getmetatable(core.active_view) == DocView
     and not core.active_view.doc:has_selection()
end

command.add(predicate, {
  ["autoinsert:backspace"] = function()
    local doc = core.active_view.doc
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

  ["autoinsert:delete-to-previous-word-start"] = function()
    local doc = core.active_view.doc
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








--]]






-- --[[



-- -- mod-version:3
-- local core = require "core"
-- local translate = require "core.doc.translate"
-- local config = require "core.config"
-- local common = require "core.common"
-- local DocView = require "core.docview"
-- local command = require "core.command"
-- local keymap = require "core.keymap"


-- config.plugins.autoinsert = common.merge({ map = {
--   ["["] = "]",
--   ["{"] = "}",
--   ["("] = ")",
--   ['"'] = '"',
--   ["'"] = "'",
--   ["`"] = "`",
-- } }, config.plugins.autoinsert)


-- local function is_closer(chr)
--   for _, v in pairs(config.plugins.autoinsert.map) do
--     if v == chr then
--       return true
--     end
--   end
-- end

-- local function count_char(text, chr)
--   local count = 0
--   local index = 1
--   while true do
--     local s, e = text:find(chr, index, true)
--     if not s then break end
--     count = count + 1
--     index = e + 1
--   end
--   return count
-- end


-- local on_text_input = DocView.on_text_input

-- function DocView:on_text_input(text)
--   local mapping = config.plugins.autoinsert.map[text]
--   local opener, closer = mapping and true, is_closer(text)

--   -- prevents plugin from operating on `CommandView`
--   if (not opener and not closer) or not self:is(DocView) then
--     return on_text_input(self, text)
--   end

--   local l1, c1, l2, c2, swap = self.doc:get_selection(true)
--   print(swap)

--   for idx, line1, col1, line2, col2, swap in self.doc:get_selections(true) do
--     if opener and closer then
--       -- if the opener and closer characters are the same
--       -- we only consider the opener case if we're not near one
--       if self.doc:get_char(line1, col1, line2, col2) == text then
--         opener = false
--       end
--     end
--     if opener then
--       -- is selection
--       if line1 ~= line2 or col1 ~= col2 then
--         self.doc:insert(line2, col2, mapping)
--         self.doc:insert(line1, col1, text)
--         print(line1, col1, line2, col2, swap)
--         self.doc:set_selections(idx, line1, col1+1, line2, col2+1, swap)
--       else
--         self.doc:text_input(text, idx)
--         -- if the opener and closer chars are the same, we only add the closer one
--         -- if there is an odd number of them in the line
--         if text ~= mapping or (text == mapping and count_char(self.doc.lines[line1], mapping) % 2 == 1) then
--           self.doc:text_input(mapping, idx)
--           self.doc:move_to_cursor(idx, -#mapping)
--         end
--       end
--     else -- closer
--       if line1 == line2 and col1 == col2 then
--         local chr = self.doc:get_char(line1, col1, line2, col2)
--         -- skip inserting closing text
--         if text == chr then
--           self.doc:move_to_cursor(idx, #text)
--         else
--           self.doc:text_input(text, idx)
--         end
--       else -- if we're in a selection we behave as normal
--         self.doc:text_input(text, idx)
--       end
--     end
--   end
-- end



-- local function predicate()
--   return getmetatable(core.active_view) == DocView
--      and not core.active_view.doc:has_selection()
-- end

-- command.add(predicate, {
--   ["autoinsert:backspace"] = function()
--     local doc = core.active_view.doc
--     local l, c = doc:get_selection()
--     local chr = doc:get_char(l, c)
--     if config.plugins.autoinsert.map[doc:get_char(l, c - 1)] and is_closer(chr) then
--       doc:delete_to(1)
--     end
--     command.perform "doc:backspace"
--   end,

--   ["autoinsert:delete-to-previous-word-start"] = function()
--     local doc = core.active_view.doc
--     local le, ce = translate.previous_word_start(doc, doc:get_selection())
--     while true do
--       local l, c = doc:get_selection()
--       if l == le and c == ce then
--         break
--       end
--       command.perform "autoinsert:backspace"
--     end
--   end,
-- })

-- keymap.add {
--   ["backspace"]            = "autoinsert:backspace",
--   ["ctrl+backspace"]       = "autoinsert:delete-to-previous-word-start",
--   ["ctrl+shift+backspace"] = "autoinsert:delete-to-previous-word-start",
-- }
-- --]]
