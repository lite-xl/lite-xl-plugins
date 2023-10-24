-- Lua parser implementation of the .editorconfig spec as best understood.
-- @copyright Jefferson Gonzalez <jgmdev@gmail.com>
-- @license MIT

local core = require "core"
local config = require "core.config"

local STANDALONE = false
for i, argument in ipairs(ARGS) do
  if argument == "test" and ARGS[i+1] == "editorconfig" then
    STANDALONE = true
  end
end

---Logger that will output using lite-xl logging functions or print to
---terminal if the parser is running in standalone mode.
---@param type "log" | "error"
---@param format string
---@param ... any
local function log(type, format, ...)
  if not STANDALONE then
    core[type]("[EditorConfig]: " .. format, ...)
  else
    print("[" .. type:upper() .. "]: " .. string.format(format, ...))
  end
end

---Represents an .editorconfig path rule/expression.
---@class plugins.editorconfig.parser.rule
---Path expression as found between square brackets.
---@field expression string | table<integer,string>
---The expression converted to a regex.
---@field regex string | table<integer,string>
---@field regex_compiled any? | table<integer,string>
---@field negation boolean Indicates that the expression is a negation.
---@field ranges table<integer,number> List of ranges found on the expression.

---Represents a section of the .editorconfig with all its config options.
---@class plugins.editorconfig.parser.section
---@field rule plugins.editorconfig.parser.rule
---@field equivalent_rules plugins.editorconfig.parser.rule[]
---@field indent_style "tab" | "space"
---@field indent_size integer
---@field tab_width integer
---@field end_of_line "lf" | "cr" | "crlf"
---@field charset "latin1" | "utf-8" | "utf-8-bom" | "utf-16be" | "utf-16le"
---@field trim_trailing_whitespace boolean
---@field insert_final_newline boolean

---EditorConfig parser class and filename config matching.
---@class plugins.editorconfig.parser
---@field config_path string
---@field sections plugins.editorconfig.parser.section[]
---@field root boolean
local Parser = {}
Parser.__index = Parser

---Constructor
---@param config_path string
---@return plugins.editorconfig.parser
function Parser.new(config_path)
  local self = {}
  setmetatable(self, Parser)
  self.config_path = config_path
  self.sections = {}
  self.root = false
  self:read()
  return self
end

--- char to hex cache and automatic converter
---@type table<string,string>
local hex_value = {}
setmetatable(hex_value, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      v = string.format("%x", string.byte(k))
      rawset(t, k, v)
    end
    return v
  end
})

---Simplifies managing rules with other inner rules like {...} which can
---contain escaped \\{ \\} and expressions that are easier handled after
---converting the escaped special characters to \xXX counterparts.
---@param value string
---@return string escaped_values
local function escapes_to_regex_hex(value)
  local escaped_chars = {}
  for char in value:ugmatch("\\(.)") do
    table.insert(escaped_chars, char)
  end
  for _, char in ipairs(escaped_chars) do
    value = value:ugsub("\\" .. char, "\\x" .. hex_value[char])
  end
  return value
end

---An .editorconfig path expression to regex conversion rule.
---@class rule
---@field rule string Lua pattern.
---Callback conversion function.
---@field conversion fun(match:string, section:plugins.editorconfig.parser.section):string

---List of conversion rules applied to brace expressions.
---@type rule[]
local RULES_BRACES = {
  { rule = "^%(",   conversion = function() return "\\(" end },
  { rule = "^%)",   conversion = function() return "\\)" end },
  { rule = "^%.",   conversion = function() return "\\." end },
  { rule = "^\\%[", conversion = function() return "\\[" end },
  { rule = "^\\%]", conversion = function() return "\\]" end },
  { rule = "^\\!",  conversion = function() return "!" end },
  { rule = "^\\;",  conversion = function() return ";" end },
  { rule = "^\\#",  conversion = function() return "#" end },
  { rule = "^\\,",  conversion = function() return "," end },
  { rule = "^\\{",  conversion = function() return "{" end },
  { rule = "^\\}",  conversion = function() return "}" end },
  { rule = "^,",    conversion = function() return "|" end },
  { rule = "^\\%*", conversion = function() return "\\*" end },
  { rule = "^%*",   conversion = function() return "[^\\/]*" end },
  { rule = "^%*%*", conversion = function() return ".*" end },
  { rule = "^%?",   conversion = function() return "." end },
  { rule = "^{}",   conversion = function() return "{}" end },
  { rule = "^{[^,]+}", conversion = function(match) return match end },
  { rule = "^%b{}",
    conversion = function(match)
      local out = match:ugsub("%(", "\\(")
        :ugsub("%)", "\\)")
        :ugsub("%.", "\\.")
        :ugsub("\\%[", "[\\[]")
        :ugsub("\\%]", "[\\]]")
        :ugsub("^\\!", "!")
        :ugsub("^\\;", ";")
        :ugsub("^\\#", "#")
        -- negation chars list
        :ugsub("%[!(%a+)%]", "[^%1]")
        :ugsub("\\\\", "[\\]")
        -- escaped braces
        :ugsub("\\{", "[{]")
        :ugsub("\\}", "[}]")
        -- non escaped braces
        :ugsub("{([^%]])", "(%1")
        :ugsub("}([^%]])", ")%1")
        :ugsub("^{", "(")
        :ugsub("}$", ")")
        -- escaped globs
        :ugsub("\\%*", "[\\*]")
        :ugsub("\\%?", "[\\?]")
        -- non escaped globs
        :ugsub("%*%*", "[*][*]") -- prevent this glob from expanding to next sub
        :ugsub("%*([^%]])", "[^\\/]*%1")
        :ugsub("%[%*%]%[%*%]", ".*")
        :ugsub("%?([^%]])", ".%1")
        -- escaped comma
        :ugsub("\\,", "[,]")
        -- non escaped comma
        :ugsub(",([^%]])", "|%1")
      return out
    end
  },
  { rule = "^%[[^/%]]*%]",
    conversion = function(match)
      local negation = match:umatch("^%[!")
      local chars = match:umatch("^%[!?(.-)%]")
      chars = chars:ugsub("^%-", "\\-"):ugsub("%-$", "\\-")
      local out = ""
      if negation then
        out = "[^"..chars.."]"
      else
        out = "["..chars.."]"
      end
      return out
    end
  },
}

---List of conversion rules applied to .editorconfig path expressions.
---@type rule[]
local RULES = {
  -- normalize escaped .editorconfig special chars or keep them escaped
  { rule = "^\\x[a-fA-F][a-fA-F]", conversion = function(match) return match end },
  { rule = "^\\%*", conversion = function() return "\\*" end },
  { rule = "^\\%?", conversion = function() return "\\?" end },
  { rule = "^\\{",  conversion = function() return "{" end },
  { rule = "^\\}",  conversion = function() return "}" end },
  { rule = "^\\%[",  conversion = function() return "\\[" end },
  { rule = "^\\%]",  conversion = function() return "\\]" end },
  { rule = "^\\!",  conversion = function() return "!" end },
  { rule = "^\\;",  conversion = function() return ";" end },
  { rule = "^\\#",  conversion = function() return "#" end },
  -- escape special chars
  { rule = "^%.",   conversion = function() return "\\." end },
  { rule = "^%(",   conversion = function() return "\\(" end },
  { rule = "^%)",   conversion = function() return "\\)" end },
  { rule = "^%[[^/%]]*%]",
    conversion = function(match)
      local negation = match:umatch("^%[!")
      local chars = match:umatch("^%[!?(.-)%]")
      chars = chars:ugsub("^%-", "\\-"):ugsub("%-$", "\\-")
      local out = ""
      if negation then
        out = "[^"..chars.."]"
      else
        out = "["..chars.."]"
      end
      return out
    end
  },
  -- Is this negation rule valid?
  { rule = "^!%w+",
    conversion = function(match)
      local chars = match:umatch("%w+")
      return "[^"..chars.."]"
    end
  },
  -- escape square brackets
  { rule = "^%[",   conversion = function() return "\\[" end },
  { rule = "^%]",   conversion = function() return "\\]" end },
  -- match any characters
  { rule = "^%*%*", conversion = function() return ".*" end },
  -- match any characters excluding path separators, \ not needed but just in case
  { rule = "^%*",   conversion = function() return "[^\\/]*" end },
  -- match optional character, doesn't matters what or should only be a \w?
  { rule = "^%?",   conversion = function() return "[^/]" end },
  -- threat empty braces literally
  { rule = "^{}",   conversion = function() return "{}" end },
  -- match a number range
  { rule = "^{%-?%d+%.%.%-?%d+}",
    conversion = function(match, section)
      local min, max = match:umatch("(-?%d+)%.%.(-?%d+)")
      min = tonumber(min)
      max = tonumber(max)
      if min and max then
        if not section.rule.ranges then section.rule.ranges = {} end
        table.insert(section.rule.ranges, {
          math.min(min, max),
          math.max(min, max)
        })
      end
      local minus = ""
      if min < 0 or max < 0 then minus = "\\-?" end
      return "(?<!0)("..minus.."[1-9]\\d*)"
    end
  },
  -- threat single option braces literally
  { rule = "^{[^,]+}", conversion = function(match) return match end },
  -- match invalid range
  { rule = "^{[^%.]+%.%.[^%.]+}", conversion = function(match) return match end },
  -- match any of the strings separated by commas inside the curly braces
  { rule = "^%b{}",
    conversion = function(rule, section)
      rule = rule:gsub("^{", ""):gsub("}$", "")
      local pos, len, exp = 1, rule:ulen(), ""

      while pos <= len do
        local found = false
        for _, r in ipairs(RULES_BRACES) do
          local match = rule:umatch(r.rule, pos)
          if match then
            exp = exp .. r.conversion(match, section)
            pos = pos + match:ulen()
            found = true
            break
          end
        end
        if not found then
          exp = exp .. rule:usub(pos, pos)
          pos = pos + 1
        end
      end

      return "(" .. exp .. ")"
    end
  }
}

---Adds the regex equivalent of a section path expression.
---@param section plugins.editorconfig.parser.section | string
---@return plugins.editorconfig.parser.section
function Parser:rule_to_regex(section)
  if type(section) == "string" then
    section = {rule = {expression = section}}
  end

  local rule = section.rule.expression

  -- match everything rule which is different from regular *
  -- that doesn't matches path separators
  if rule == "*" then
    section.rule.regex = ".+"
    section.rule.regex_compiled = regex.compile(".+")
    return section
  end

  rule = escapes_to_regex_hex(section.rule.expression)

  local pos, len, exp = 1, rule:ulen(), ""

  -- if expression starts with ! it is treated entirely as a negation
  local negation = rule:umatch("^%s*!")
  if negation then
    pos = pos + negation:ulen() + 1
  end

  -- apply all conversion rules by looping the path expression/rule
  while pos <= len do
    local found = false
    for _, r in ipairs(RULES) do
      local match = rule:umatch(r.rule, pos)
      if match then
        exp = exp .. r.conversion(match, section)
        pos = pos + match:ulen()
        found = true
        break
      end
    end
    if not found then
      exp = exp .. rule:usub(pos, pos)
      pos = pos + 1
    end
  end

  -- force match up to the end
  exp = exp .. "$"

  -- allow expressions that start with * to match anything on start
  if exp:match("^%[^\\/%]%*") then
    exp = exp:gsub("^%[^\\/%]%*", ".*")
  -- fixes two failing tests
  elseif exp:match("^%[") then
    exp = "^" .. exp
  -- match only on root dir
  elseif exp:match("^/") then
    exp = exp:gsub("^/", "^")
  end

  -- store changes to the section rule
  section.rule.regex, section.rule.negation = exp, negation
  section.rule.regex_compiled = regex.compile(section.rule.regex)
  if not section.rule.regex_compiled then
    log(
      "error",
      "could not compile '[%s]' to regex '%s'",
      rule, section.rule.regex
    )
  end

  return section
end

---Parses the associated .editorconfig file and stores each section.
function Parser:read()
  local file = io.open(self.config_path, "r")

  self.sections = {}

  if not file then
    log("log", "could not read %s", self.config_path)
    return
  end

  ---@type plugins.editorconfig.parser.section
  local section = {}

  for line in file:lines() do
    ---@cast line string

    -- first we try to see if the line is a rule section
    local rule = ""
    rule = line:umatch("^%s*%[(.+)%]%s*$")
    if rule then
      if section.rule then
        -- save previous section and crerate new one
        table.insert(self.sections, section)
        section = {}
      end
      section.rule = {
        expression = rule
      }
      -- convert the expression to a regex directly on the section table
      self:rule_to_regex(section)

      local clone = rule
      if clone:match("//+") or clone:match("/%*%*/") then
        section.equivalent_rules = {}
      end
      while clone:match("//+") or clone:match("/%*%*/") do
        ---@type plugins.editorconfig.parser.section[]
        if clone:match("//+") then
          clone = clone:ugsub("//+", "/", 1)
          table.insert(section.equivalent_rules, self:rule_to_regex(clone).rule)
        end
        if clone:match("/%*%*/") then
          clone = clone:ugsub("/%*%*/", "/", 1)
          table.insert(section.equivalent_rules, self:rule_to_regex(clone).rule)
        end
      end
    end

    if not rule then
      local name, value = line:umatch("^%s*(%w%S+)%s*=%s*([^\n\r]+)")
      if name and value then
        name = name:ulower()
        -- do not lowercase property values that start with test_
        if not name:match("^test_") then
          value = value:ulower()
        end
        if value == "true" then
          value = true
        elseif value == "false" then
          value = false
        elseif math.tointeger and math.tointeger(value) then
          value = math.tointeger(value)
        elseif tonumber(value) then
          value = tonumber(value)
        end

        if section.rule then
          section[name] = value
        elseif name == "root" and type(value) == "boolean" then
          self.root = value
        end
      end
    end
  end

  if section.rule then
    table.insert(self.sections, section)
  end
end

---Helper function that converts a regex offset results into a list
---of strings, omitting the first result which is the complete match.
---@param offsets table<integer,integer>
---@param value string
---@return table<integer, string>
local function regex_result_to_table(offsets, value)
  local result = {}
  local offset_fix = 0
  if not regex.find_offsets then
    offset_fix = 1
  end
  for i=3, #offsets, 2 do
    table.insert(result, value:sub(offsets[i], offsets[i+1]-offset_fix))
  end
  return result
end

---Get a matching config for the given filename or nil if nothing found.
---@param file_name string
---@param defaults? boolean Set indent size to defaults when needed,
---@return plugins.editorconfig.parser.section?
function Parser:getConfig(file_name, defaults)
  if PLATFORM == "Windows" then
    file_name = file_name:gsub("\\", "/")
  end

  local regex_match = regex.match
  if regex.find_offsets then
    regex_match = regex.find_offsets
  end

  local properties = {}

  local found = false
  for _, section in ipairs(self.sections) do
    if section.rule.regex_compiled then
      local negation = section.rule.negation
      -- default rule
      local matched = {regex_match(section.rule.regex_compiled, file_name)}
      -- try equivalent rules if available
      if not matched[1] and section.equivalent_rules then
        for _, esection in ipairs(section.equivalent_rules) do
          matched = {regex_match(esection.regex_compiled, file_name)}
          if matched[1] then
            break
          end
        end
      end
      if (matched[1] and not negation) or (not matched[1] and negation) then
        local ranges_match = true
        if section.rule.ranges then
          local results = regex_result_to_table(matched, file_name)
          if #results < #section.rule.ranges then
            ranges_match = false
          else
            for i, range in ipairs(section.rule.ranges) do
              local number = tonumber(results[i])
              if not number then
                ranges_match = false
                break
              end
              if number < range[1] or number > range[2] then
                ranges_match = false
                break
              end
            end
          end
        end
        if ranges_match then
          found = true
          for name, value in pairs(section) do
            if name ~= "rule" and name ~= "equivalent_rules" then
              properties[name] = value
            end
          end
        end
      end
    end
  end

  if found and defaults then
    if properties.indent_style and properties.indent_style == "space" then
      if properties.indent_size and not properties.tab_width then
        properties.tab_width = 4
      end
    elseif properties.indent_style and properties.indent_style == "tab" then
      if not properties.tab_width and not properties.indent_size then
        properties.indent_size = "tab"
      elseif properties.tab_width then
        properties.indent_size = properties.tab_width
      end
    end
  end

  return found and properties or nil
end

---Get a matching config for the given filename or nil if nothing found.
---@param file_name string
---@return string
function Parser:getConfigString(file_name)
  local out = ""
  local properties = self:getConfig(file_name, true)
  if properties then
    local config_sorted = {}
    for name, value in pairs(properties) do
      table.insert(config_sorted, {name = name, value = value})
    end
    table.sort(config_sorted, function(a, b)
      return a.name < b.name
    end)
    for _, value in ipairs(config_sorted) do
      out = out .. value.name .. "=" .. tostring(value.value) .. "\n"
    end
  end
  return out
end

return Parser
