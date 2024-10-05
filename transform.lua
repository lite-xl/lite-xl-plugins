-- mod-version:3
local command = require "core.command"
local keymap = require "core.keymap"
local config = require "core.config"

-- |-------------------------|
-- |        Transform        |
-- |-------------------------|

--[[

  The Transform plugin provides commands for transforming text
  into the specified case.

  this plugin supports multiple cursors.

  if a selection is highlighted,
    the transformation will be performed on
    the entire selection

  if not,
    the transformation will be performed on
    the word under the cursor
    the word will be determined using the nonWordChars settings value
      -- if a change is made to this setting the plugin will need to be reloaded

]]

local command_prefix = "Transform"
local command_names = {
  ["snake_case"]      = command_prefix .. ": To snake_case",
  ["camel_case"]      = command_prefix .. ": To camelCase",
  ["pascal_case"]     = command_prefix .. ": To PascalCase",
  -- determine how to display "-" in commandview
  ["kebab_case"]      = command_prefix .. ": To kebab-case (hyphen)",
  ["uppercase"]       = command_prefix .. ": To UPPERCASE",
  ["lowercase"]       = command_prefix .. ": To lowercase",
  ["capitalize_word"] = command_prefix .. ": Capitalize Word",
  ["uppercase_next"]  = command_prefix .. ": Uppercase Next Char",
  ["lowercase_next"]  = command_prefix .. ": lowercase Next Char",
}

-- Retrieve non-word characters from the Lite XL settings
local nonWordChars = config.non_word_chars
local nonWordCharsSet = {[" "]=true}
for i = 1, #nonWordChars do
    local char = nonWordChars:sub(i, i)
    nonWordCharsSet[char] = true
end

--   Feature?
-- ------------
-- allow the user to define "wordPartSeparators"


local function get_selected_text(document, line1, col1, line2, col2)
  -- if first position does not match second position
  if line1 ~= line2 or col1 ~= col2 then

    --   There is a selection
    -- ------------------------
    local selected_text = document:get_text(line1, col1, line2, col2)
    return line1, col1, line2, col2, selected_text
  else

    --   No selection, get the word under the cursor
    -- -----------------------------------------------
    local text = document.lines[line1]
    -- Find the start of the word
    local word_start = col1
    while word_start > 1 and not nonWordCharsSet[text:sub(word_start - 1, word_start - 1)] do
      word_start = word_start - 1
    end
    -- Find the end of the word
    local word_end = col1
    while word_end <= #text and not nonWordCharsSet[text:sub(word_end, word_end)] do
      word_end = word_end + 1
    end
    local selected_text = text:sub(word_start, word_end - 1)
    return line1, word_start, line1, word_end, selected_text
  end
end

local function split(s)
  local result = {}
  -- wordPartSeparators would be used here
  for part in s:gmatch("([^-_ \n\t]+)") do
    table.insert(result, part)
  end
  return result
end

local function for_each_selection_of_doc(document, func, get_word)
    get_word = get_word == nil and true or get_word
    for idx, line1, col1, line2, col2 in document:get_selections(true) do
      if get_word then
        -- args: cursor_index, start_line, start_col, end_line, end_col, selected_text
        func(idx, get_selected_text(document, line1, col1, line2, col2))
      else
        func(idx, line1, col1, line2, col2, document:get_text(line1, col1, line2, col2))
      end
    end
end


---transforms the word or selection using the specified separator and clean function
---@param document core.doc: the document (dv.doc)
---@param word_part_join_value string: a string value to join the word parts with
---@param word_part_clean fun(word_part: string, i: number) | nil must return the cleaned word_part
local function transform(document, word_part_join_value , word_part_clean)
    if word_part_clean == nil then
      word_part_clean = function (w,i) return w end
    end
    for_each_selection_of_doc(document, function(cursor_index, start_line, start_col, end_line, end_col, selected_text)

      --   split word parts
      -- --------------------
      -- by (lower)(upper)
      selected_text = selected_text:gsub("([%l%d])([%u])", "%1_%2")
      -- by single (upper)s
      selected_text = selected_text:gsub("([%u%d])(%u)(%l)", "%1_%2%3")
      local parts = split(selected_text)

      -- clean each word part
      for i,word_part in ipairs(parts) do
        parts[i] = word_part_clean(word_part, i)
      end

      local transformed_text = table.concat(parts, word_part_join_value)
      document:replace_cursor(cursor_index,start_line,start_col,end_line,end_col, function () return transformed_text end)
      document:move_to_cursor(cursor_index,0,#transformed_text)
    end)
end

local function capitalize(word)
  return word:sub(1, 1):upper() .. word:sub(2):lower()
end


-- |----------------------------------|
-- |        Transform Commands        |
-- |----------------------------------|

--   To Snake_Case
-- -----------------
command.add("core.docview", {
  [command_names.snake_case] = function(dv)
    transform(dv.doc, "_", function(word_part)
      return word_part:lower()
    end)
  end,
})

--   To camelCase
-- ----------------
command.add("core.docview", {
  [command_names.camel_case] = function(dv)
    transform(dv.doc, "", function(word_part, i)
      if i==1 then
        return word_part:lower()
      else
        return capitalize(word_part)
      end
    end)
  end,
})

--   To PascalCase
-- -----------------
command.add("core.docview", {
  [command_names.pascal_case] = function(dv)
    transform(dv.doc, "", capitalize)
  end,
})

--   To kebab-case
-- -----------------
command.add("core.docview", {
  [command_names.kebab_case] = function(dv)
    transform(dv.doc, "-")
  end,
})

--   To UPPERCASE
-- ----------------
command.add("core.docview", {
  [command_names.uppercase] = function(dv)
    local document = dv.doc
    for_each_selection_of_doc(
      document,
      function (cursor_index, start_line, start_col, end_line, end_col, selected_text)
        document:replace_cursor(cursor_index,start_line, start_col, end_line, end_col,
        function ()
          return selected_text:upper()
        end)
      end
    )
  end,
})

--   To lowercase
-- ----------------
command.add("core.docview", {
  [command_names.lowercase] = function(dv)
      local document = dv.doc
      for_each_selection_of_doc(
      document,
      function (cursor_index, start_line, start_col, end_line, end_col, selected_text)
        document:replace_cursor(cursor_index,start_line, start_col, end_line, end_col,
        function ()
          return selected_text:lower()
        end)
      end
    )
  end,
})


--   Capitalize Word
-- -------------------
command.add("core.docview", {
  [command_names.capitalize_word] = function(dv)
    local document = dv.doc
    for_each_selection_of_doc(
      document,
      function (cursor_index, start_line, start_col, end_line, end_col, selected_text)
        document:replace_cursor(cursor_index, start_line, start_col, end_line, end_col,
        function ()
          local words = split(selected_text)
          for i,word in ipairs(words) do
            words[i] = capitalize(word)
          end
          return table.concat(words," ")
        end)
      end
    )
  end,
})

--   Uppercase Next Char
-- -----------------------
command.add("core.docview", {
  [command_names.uppercase_next] = function(dv)
    local document = dv.doc
    for_each_selection_of_doc(
      document,
      function (cursor_index, start_line, start_col)
        document:replace_cursor(cursor_index, start_line, start_col, start_line, start_col+1,
        function (text)
          return text:upper()
        end)
        document:move_to_cursor(cursor_index,0,1)
      end,
      -- get_word =
      false
    )
  end,
})

--   lowercase Next Char
-- -----------------------
command.add("core.docview", {
  [command_names.lowercase_next] = function(dv)
    local document = dv.doc
    for_each_selection_of_doc(
      document,
      function (cursor_index, start_line, start_col)
        document:replace_cursor(cursor_index, start_line, start_col, start_line, start_col+1,
        function (text)
          return text:lower()
        end)
        document:move_to_cursor(cursor_index,0,1)
      end,
      -- get_word =
      false
    )
  end,
})


-- not sure best way to add a keybind for both platforms
keymap.add {
  ["cmd+option+u"] = command_names.uppercase_next,
  ["cmd+option+l"] = command_names.lowercase_next,
  -- ["ctrl+alt+u"] = command_names.uppercase_next,
  -- ["ctrl+alt+l"] = command_names.lowercase_next,
}
