-- mod-version:3
local core = require "core"
local command = require "core.command"

local function is_lower(str)
  local is_lowercase = true
  for c in string.gmatch(str, ".") do
      if not string.match(c,"%l")
          and not string.match(c,"%d")
          and not string.match(c,"%s")
          and not string.match(c,"%c")
          and not string.match(c,"%p")
          then
              is_lowercase = false
              break
          end
      end

      return is_lowercase
  end

  local function is_upper(str)
    local is_uppercase = true
    for c in string.gmatch(str, ".") do
      if not string.match(c,"%u")
          and not string.match(c,"%d")
          and not string.match(c,"%s")
          and not string.match(c,"%c")
          and not string.match(c,"%p")
          then
              is_uppercase = false
              break
          end
      end

      return is_uppercase
  end

  local function capitalize(s)
    return (s:gsub('(%S)(%S*)',function(g,r)
        return g:upper()..r:lower()
    end))
end

local function is_title(s)
    return s:sub(1,1):match("%u")
end

local function parse_case(text, preserve_case)
  local upper_pattern  = "^[A-Z]$"
  local sep_pattern = "^[^a-zA-Z0-9]$"
  local notsep_pattern = "^[a-zA-Z0-9]$"
  preserve_case = preserve_case or false
  local words = {}
  local has_sep = nil
  local i = 1
  local s = 0
  local p = string.sub(text, 1, 1)
  local was_upper = false
  if is_upper(text) then
    was_upper = true
    text = string.lower(text)
end

while i <= string.len(text)  do
    local c = text:sub(i, i+1):sub(2,2)
    local split = false
    if i < string.len(text) then
      if c:match(upper_pattern) then
        split = true
    elseif c:match(notsep_pattern) and p:match(sep_pattern) then
        split = true
    elseif c:match(sep_pattern) and p:match(notsep_pattern) then
        split = true
    end
else
  split = true
end

if split then
  if p:match(notsep_pattern) then
    table.insert(words, text:sub(s+1,i))
else
    if not has_sep then
      has_sep = text:sub(s+1,s+1)
  end
end
s = i
end
i = i + 1
p = c
end

local case_type = "unknown"
if was_upper then
    case_type = 'upper'
elseif is_lower(text) then
    case_type = "lower"
elseif #words > 0 then
    local camelCase = is_lower(words[1])
    local pascalCase = is_title(words[1]) or is_upper(words[1])

    if camelCase or pascalCase then
      for w = 2, #words do
        local c = is_title(words[w]) or is_upper(words[w])
        camelCase = camelCase and c
        pascalCase = pascalCase and c
        if not c then break end
    end
    if camelCase then
        case_type = "camel"
    elseif pascalCase then
        case_type = "pascal"
    else
        case_type = 'mixed'
    end
end
end

if preserve_case then
    if was_upper then
      for w = 1, #words do
        words[w] = words[w].upper()
    end
end
else
    for w = 1, #words do
      words[w] = capitalize(words[w])
  end
end
return words, case_type, has_sep

end

local function to_snake_case(text)
  local words = parse_case(text)
  local lower_words = {}
  for w = 1, #words do
    table.insert(lower_words, words[w]:lower())
end
return table.concat(lower_words, "_")
end

local function to_screaming_snake_case(text)
  local words = parse_case(text)
  local lower_words = {}
  for w = 1, #words do
    table.insert(lower_words, words[w]:upper())
end
return table.concat(lower_words, "_")
end

local function to_pascal_case(text)
  local words = parse_case(text)
  return table.concat(words, "")
end

local function to_camel_case(text)
  local words = parse_case(text)
  words[1] = string.lower(words[1])
  return table.concat(words, "")
end

local function to_dot_case(text)
  local words = parse_case(text)
  local lower_words = {}
  for w = 1, #words do
    table.insert(lower_words, words[w]:lower())
end
return table.concat(lower_words, ".")
end

local function to_kebab_case(text)
  local words = parse_case(text)
  local lower_words = {}
  for w = 1, #words do
    table.insert(lower_words, words[w]:lower())
end
return table.concat(lower_words, "-")
end

local function to_slash(text)
  local words = parse_case(text)
  return table.concat(words, "/")
end

local function to_backslash(text)
  local words = parse_case(text)
  return table.concat(words, "\\")
end

local function to_separate_words(text)
  local words = parse_case(text)
  return table.concat(words, " ")
end

local function toggle_case(text)
  local _, case, sep = parse_case(text)
  if case == "pascal" and not sep then
    return to_snake_case(text)
elseif case == "lower" and sep == "_" then
    return to_camel_case(text)
elseif case == "camel" and not sep then
    return to_pascal_case(text)
end

return text
end

command.add("core.docview", {
  ["transform:snake_case"] = function()
    core.active_view.doc:replace(function(text)
      return to_snake_case(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:SCREAMING_SNAKE_CASE"] = function()
    core.active_view.doc:replace(function(text)
      return to_screaming_snake_case(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:camelCase"] = function()
    core.active_view.doc:replace(function(text)
      return to_camel_case(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:PascalCase"] = function()
    core.active_view.doc:replace(function(text)
      return to_pascal_case(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:dot.case"] = function()
    core.active_view.doc:replace(function(text)
      return to_dot_case(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:kebab-case"] = function()
    core.active_view.doc:replace(function(text)
      return to_kebab_case(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:separate words"] = function()
    core.active_view.doc:replace(function(text)
      return to_separate_words(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:slash/words"] = function()
    core.active_view.doc:replace(function(text)
      return to_slash(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:backslash\\words"] = function()
    core.active_view.doc:replace(function(text)
      return to_backslash(text)
  end)
end,
})

command.add("core.docview", {
  ["transform:toggle_pascal_snake_camel"] = function()
    core.active_view.doc:replace(function(text)
      return toggle_case(text)
  end)
end,
})
