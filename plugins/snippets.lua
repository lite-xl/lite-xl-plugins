-- mod-version:3

--[[
Define new snippets in the config.snippets table. The first snippet defined, config.snippets.lua.f
defines the "f" snippet for files that have the ".lua" extension. If you want to define the "def"
snippet for Python files, you'd do "config.snippets.py.def", after initializing the py table.

Snippet insert positions are defined by "$number", and whenever you press tab you will be moved to
the next number. If there are multiple insertion points for the same number then whatever is typed
will be inserted at all those points simultaneously. Pressing ESCAPE cancels the current snippet
function, reaching its end and pressing TAB once more also cancels it.
]]--

local config = require "core.config"

config.snippets = {}

config.snippets.lua = {}
config.snippets.lua.f = [[
function $1()
  $2
end
]]

local command = require "core.command"
local keymap = require "core.keymap"
local core = require "core"
local translate = require "core.doc.translate"
local Doc = require "core.doc"

local snippet_insert_positions = {}
local snippet_lines = {}
local snippet_index = 0
local snippet_max_index = 0
local current_col_offset = 0
local in_snippet = false

local function dv()
  return core.active_view
end

local function doc()
  return core.active_view.doc
end

function Doc:text_input(text)
  if self:has_selection() then
    self:delete_to()
  end
  if in_snippet then
    local moved = false
    for i, p in ipairs(snippet_insert_positions) do
      if p.snippet_number == snippet_index then
        self:insert(p.line, p.col + current_col_offset, text)
        if not moved then
          self:move_to(#text)
          moved = true
        end
      end
    end
    current_col_offset = current_col_offset + 1
  else
    local line, col = self:get_selection()
    self:insert(line, col, text)
    self:move_to(#text)
  end
end

local function reset_snippet_vars()
  in_snippet = false
  current_col_offset = 0
  snippet_index = 0
  snippet_max_index = 0
  snippet_insert_positions = {}
  snippet_lines = {}
end

local on_key_pressed = keymap.on_key_pressed

function keymap.on_key_pressed(k, ...)
  if in_snippet then
    if k == "escape" or k == "return" then
      reset_snippet_vars()
    elseif k == "backspace" then
      local did_keymap = false
      for i = #snippet_insert_positions, 1, -1 do
        local p = snippet_insert_positions[i]
        if p.snippet_number == snippet_index then
          doc():set_selection(p.line, p.col + current_col_offset, p.line, p.col + current_col_offset)
          doc():delete_to(translate.previous_char)
        end
      end
      current_col_offset = current_col_offset - 1
      return did_keymap
    end
  end
  local did_keymap = on_key_pressed(k, ...)
  return did_keymap
end

command.add("core.docview", {
  ["snippets:expand"] = function()
    if in_snippet then
      current_col_offset = 0
      snippet_index = snippet_index + 1
      for _, p in ipairs(snippet_insert_positions) do
        if p.snippet_number == snippet_index then
          doc():set_selection(p.line, p.col, p.line, p.col)
          break
        end
      end
      if snippet_index > snippet_max_index then
        reset_snippet_vars()
      end
    else
      local line, col = doc():get_selection()
      local indent = doc().lines[line]:match("^[\t ]*")
      local extension
      if doc().filename then
        extension = doc().filename:match("%.[%w]+$")
      end
      if extension then
        extension = extension:sub(2, -1)
        if config.snippets[extension] then
          -- find previous word to check for snippet expansion
          local word_col = 1
          for i = col, 1, -1 do
            local c = doc().lines[line]:sub(i, i)
            if c == " " then
              word_col = i+1
              break
            end
          end
          local pre_text = doc().lines[line]:sub(1, word_col-1)
          local text = doc().lines[line]:sub(word_col, col-1)
          for snippet_name, snippet_string in pairs(config.snippets[extension]) do
            if text == snippet_name then
              snippet_lines = {}
              for line in snippet_string:gmatch(".-[\n\r]") do
                table.insert(snippet_lines, line)
              end
              snippet_max_index = 0
              -- tag positions with snippet insertion points (marked by $)
              for i, line_str in ipairs(snippet_lines) do
                for j, p in line_str:gmatch("()%$([%d]+)") do
                  if tonumber(p) > snippet_max_index then
                    snippet_max_index = tonumber(p)
                  end
                  table.insert(snippet_insert_positions, {snippet_number = tonumber(p), line = line + (i-1), col = col + j - #text - 1})
                end
              end
              snippet_index = snippet_index + 1
              snippet_string = snippet_string:gsub("%$[%d]+", "")
              doc():delete_to(function() return line, word_col end, dv())
              for i, line in ipairs(snippet_lines) do
                if i == 1 then
                  doc():text_input(line:gsub("$[%d]+", ""))
                else
                  doc():text_input(indent .. line:gsub("%$[%d]+", ""))
                end
              end
              for _, p in ipairs(snippet_insert_positions) do
                if p.snippet_number == snippet_index then
                  doc():set_selection(p.line, p.col, p.line, p.col)
                  break
                end
              end
              in_snippet = true
              break
            end
          end
        end
      end
      -- fallthrough in case previous word wasn't a snippet, just defaults to normal tab behavior
      if not in_snippet then
        local performed = command.perform("command:complete")
        if not performed then
          command.perform("doc:indent")
        end
      end
    end
  end
})

keymap.add {
  ["tab"] = "snippets:expand",
}
