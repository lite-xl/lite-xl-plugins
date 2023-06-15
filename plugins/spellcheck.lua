-- mod-version:3
local core = require "core"
local style = require "core.style"
local config = require "core.config"
local command = require "core.command"
local common = require "core.common"
local DocView = require "core.docview"
local Highlighter = require "core.doc.highlighter"
local Doc = require "core.doc"

local platform_dictionary_file
if PLATFORM == "Windows" then
  platform_dictionary_file = EXEDIR .. "/words.txt"
else
  platform_dictionary_file = "/usr/share/dict/words"
end

config.plugins.spellcheck = common.merge({
  enabled = true,
  files = { "%.txt$", "%.md$", "%.markdown$" },
  dictionary_file = platform_dictionary_file
}, config.plugins.spellcheck)

local last_input_time = 0
local word_pattern = "%a+"
local words

local spell_cache = setmetatable({}, { __mode = "k" })
local font_canary
local font_size_canary


-- Move cache to make space for new lines
local prev_insert_notify = Highlighter.insert_notify
function Highlighter:insert_notify(line, n, ...)
  prev_insert_notify(self, line, n, ...)
  local blanks = { }
  if not spell_cache[self] then
    spell_cache[self] = {}
  end
  for i = 1, n do
    blanks[i] = false
  end
  common.splice(spell_cache[self], line, 0, blanks)
end


-- Close the cache gap created by removed lines
local prev_remove_notify = Highlighter.remove_notify
function Highlighter:remove_notify(line, n, ...)
  prev_remove_notify(self, line, n, ...)
  if not spell_cache[self] then
    spell_cache[self] = {}
  end
  common.splice(spell_cache[self], line, n)
end


-- Remove changed lines from the cache
local prev_tokenize_line = Highlighter.tokenize_line
function Highlighter:tokenize_line(idx, state, ...)
  local res = prev_tokenize_line(self, idx, state, ...)
  if not spell_cache[self] then
    spell_cache[self] = {}
  end
  spell_cache[self][idx] = false
  return res
end

local function reset_cache()
  for i=1,#spell_cache do
    local cache = spell_cache[i]
    for j=1,#cache do
      cache[j] = false
    end
  end
end


local function load_dictionary()
  core.add_thread(function()
    local t = {}
    local i = 0
    for line in io.lines(config.plugins.spellcheck.dictionary_file) do
      for word in line:gmatch(word_pattern) do
        t[word:lower()] = true
      end
      i = i + 1
      if i % 1000 == 0 then coroutine.yield() end
    end
    words = t
    core.redraw = true
    core.log_quiet(
      "Finished loading dictionary file: \"%s\"",
      config.plugins.spellcheck.dictionary_file
    )
  end)
end


local function matches_any(filename, ptns)
  for _, ptn in ipairs(ptns) do
    if filename:find(ptn) then return true end
  end
end


local function active_word(doc, line, tail)
  local l, c = doc:get_selection()
  return l == line and c == tail
     and doc == core.active_view.doc
     and system.get_time() - last_input_time < 0.5
end


local text_input = Doc.text_input
function Doc:text_input(...)
  text_input(self, ...)
  last_input_time = system.get_time()
end


local function compare_arrays(a, b)
  if b == a then return true end
  if not a or not b then return false end
  if #b ~= #a then return false end
  for i=1,#a do
    if b[i] ~= a[i] then return false end
  end
  return true
end


local draw_line_text = DocView.draw_line_text
function DocView:draw_line_text(idx, x, y)
  local lh = draw_line_text(self, idx, x, y)

  if
    not config.plugins.spellcheck.enabled
    or
    not words
    or
    not matches_any(self.doc.filename or "", config.plugins.spellcheck.files)
  then
    return lh
  end

  if font_canary ~= style.code_font
    or font_size_canary ~= style.code_font:get_size()
    or not compare_arrays(self.wrapped_lines, self.old_wrapped_lines)
  then
    spell_cache[self.doc.highlighter] = {}
    font_canary = style.code_font
    font_size_canary = style.code_font:get_size()
    self.old_wrapped_lines = self.wrapped_lines
    reset_cache()
  end
  if not spell_cache[self.doc.highlighter][idx] then
    local calculated = {}
    local s, e = 0, 0
    local text = self.doc.lines[idx]

    while true do
      s, e = text:find(word_pattern, e + 1)
      if not s then break end
      local word = text:sub(s, e):lower()
      if not words[word] and not active_word(self.doc, idx, e + 1) then
        local x,y = self:get_line_screen_position(idx, s)
        table.insert(calculated, x + self.scroll.x)
        table.insert(calculated, y + self.scroll.y)
        x,y = self:get_line_screen_position(idx, e + 1)
        table.insert(calculated, x + self.scroll.x)
        table.insert(calculated, y + self.scroll.y)
      end
    end

    spell_cache[self.doc.highlighter][idx] = calculated
  end

  local color = style.spellcheck_error or style.syntax.keyword2
  local h = math.ceil(1 * SCALE)
  local slh = self:get_line_height()
  local calculated = spell_cache[self.doc.highlighter][idx]
  for i=1,#calculated,4 do
    local x1, y1, x2, y2 = calculated[i], calculated[i+1], calculated[i+2], calculated[i+3]
    renderer.draw_rect(x1 - self.scroll.x, y1 + slh - self.scroll.y, x2 - x1, h, color)
  end
  return lh
end


local function get_word_at_caret()
  local doc = core.active_view.doc
  local l, c = doc:get_selection()
  local s, e = 0, 0
  local text = doc.lines[l]
  while true do
    s, e = text:find(word_pattern, e + 1)
    if c >= s and c <= e + 1 then
      return text:sub(s, e):lower(), s, e
    end
  end
end


local function compare_words(word1, word2)
  local res = 0
  for i = 1, math.max(#word1, #word2) do
    if word1:byte(i) ~= word2:byte(i) then
      res = res + 1
    end
  end
  return res
end


-- The config specification used by the settings gui
config.plugins.spellcheck.config_spec = {
  name = "Spell Check",
  {
    label = "Enabled",
    description = "Disable or enable spell checking.",
    path = "enabled",
    type = "toggle",
    default = true
  },
  {
    label = "Files",
    description = "List of Lua patterns matching files to spell check.",
    path = "files",
    type = "list_strings",
    default = { "%.txt$", "%.md$", "%.markdown$" }
  },
  {
    label = "Dictionary File",
    description = "Path to a text file that contains a list of dictionary words.",
    path = "dictionary_file",
    type = "file",
    exists = true,
    default = platform_dictionary_file,
    on_apply = function()
      load_dictionary()
    end
  }
}

load_dictionary()

command.add("core.docview", {

  ["spell-check:toggle"] = function()
    config.plugins.spellcheck.enabled = not config.plugins.spellcheck.enabled
  end,

  ["spell-check:add-to-dictionary"] = function()
    local word = get_word_at_caret()
    if words[word] then
      core.error("\"%s\" already exists in the dictionary", word)
      return
    end
    if word then
      local fp = assert(io.open(config.plugins.spellcheck.dictionary_file, "a"))
      fp:write("\n" .. word .. "\n")
      fp:close()
      words[word] = true
      core.log("Added \"%s\" to dictionary", word)
    end
  end,


  ["spell-check:replace"] = function(dv)
    local word, s, e = get_word_at_caret()

    -- find suggestions
    local suggestions = {}
    local word_len = #word
    for w in pairs(words) do
      if math.abs(#w - word_len) <= 2 then
        local diff = compare_words(word, w)
        if diff < word_len * 0.5 then
          table.insert(suggestions, { diff = diff, text = w })
        end
      end
    end
    if #suggestions == 0 then
      core.error("Could not find any suggestions for \"%s\"", word)
      return
    end

    -- sort suggestions table and convert to properly-capitalized text
    table.sort(suggestions, function(a, b) return a.diff < b.diff end)
    local doc = dv.doc
    local line = doc:get_selection()
    local has_upper = doc.lines[line]:sub(s, s):match("[A-Z]")
    for k, v in pairs(suggestions) do
      if has_upper then
        v.text = v.text:gsub("^.", string.upper)
      end
      suggestions[k] = v.text
    end

    -- select word and init replacement selector
    local label = string.format("Replace \"%s\" With", word)
    doc:set_selection(line, e + 1, line, s)
    core.command_view:enter(label, {
      submit = function(text, item)
        text = item and item.text or text
        doc:replace(function() return text end)
      end,
      suggest = function(text)
        local t = {}
        for _, w in ipairs(suggestions) do
          if w:lower():find(text:lower(), 1, true) then
            table.insert(t, w)
          end
        end
        return t
      end
    })
  end,

})

local contextmenu = require "plugins.contextmenu"
contextmenu:register("core.docview", {
  contextmenu.DIVIDER,
  { text = "View Suggestions",  command = "spell-check:replace" },
  { text = "Add to Dictionary", command = "spell-check:add-to-dictionary" }
})
