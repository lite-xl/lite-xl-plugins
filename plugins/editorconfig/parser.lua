-- Lua parser implementation of the .editorconfig spec as best understood.
-- @copyright Jefferson Gonzalez <jgmdev@gmail.com>
-- @license MIT

local core = require "core"
local Object = require "core.object"

---Represents an .editorconfig path rule/expression.
---@class plugins.editorconfig.parser.rule
---@field expression string Config expression as found between square brackets.
---@field regex string The expression converted to a regex.
---@field regex_compiled any?
---@field negation boolean Indicates that the rule is a negation.
---@field ranges table<integer,number> List of ranges found on the expression.

---Represents a section of the .editorconfig with all its config options.
---@class plugins.editorconfig.parser.section
---@field rule plugins.editorconfig.parser.rule
---@field indent_style "tab" | "space"
---@field indent_size integer
---@field tab_width integer
---@field end_of_line "lf" | "cr" | "crlf"
---@field charset "latin1" | "utf-8" | "utf-8-bom" | "utf-16be" | "utf-16le"
---@field trim_trailing_whitespace boolean
---@field insert_final_newline boolean

---EditorConfig parser class and filename config matching.
---@class plugins.editorconfig.parser : core.object
---@field config_path string
---@field sections plugins.editorconfig.parser.section[]
---@field root boolean
local Parser = Object:extend()

---Constructor
---@param config_path string
function Parser:new(config_path)
  self.config_path = config_path
  self.sections = {}
  self.root = false
  self:read()
end

---An .editorconfig path expression to regex conversion rule.
---@class rule
---@field rule string Lua pattern.
---Callback conversion function.
---@field conversion fun(match:string, section:plugins.editorconfig.parser.section):string

---List of conversion rules applied to .editorconfig path expressions.
---@type rule[]
local RULES = {
  -- normalize escaped .editorconfig special chars or keep them escaped
  { rule = "^\\%*", conversion = function() return "\\*" end },
  { rule = "^\\%?", conversion = function() return "\\?" end },
  { rule = "^\\{",  conversion = function() return "{" end },
  { rule = "^\\}",  conversion = function() return "}" end },
  { rule = "^\\[",  conversion = function() return "\\[" end },
  { rule = "^\\]",  conversion = function() return "\\]" end },
  { rule = "^\\!",  conversion = function() return "!" end },
  -- escape special chars
  { rule = "^%.",   conversion = function() return "\\." end },
  { rule = "^%(",   conversion = function() return "\\(" end },
  { rule = "^%)",   conversion = function() return "\\)" end },
  -- The .editorconfig documentation says [!chars] for negation or [chars]
  -- to negate for match any of the chars but I'm not sure if the square
  -- brackets should not be included...
  -- Is this the correct one or the one below?
  { rule = "^%b[]",
    conversion = function(match)
      local negation = match:match("%[!")
      local chars = match:match("%[!?(.-)%]")
      if negation then return "[^"..chars.."]" end
      return "["..chars.."]"
    end
  },
  -- Is this the correct one or the one above :P
  { rule = "^!%w+",
    conversion = function(match)
      local chars = match:match("%w+")
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
  { rule = "^%?",   conversion = function() return ".?" end },
  -- match a number range
  { rule = "^{%-?%d+%.%.%-?%d+}",
    conversion = function(match, section)
      local min, max = match:match("(-?%d+)%.%.(-?%d+)")
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
      return "("..minus.."\\d+)"
    end
  },
  -- match any of the strings separated by commas inside the curly braces
  { rule = "^%b{}",
    conversion = function(match)
      local out = match:gsub("%(", "\\(")
        :gsub("%)", "\\)") -- escape parenthesis just to be safe...
        :gsub("{", "(")
        :gsub(",", "|")
        :gsub("}", ")")
        :gsub("%.", "\\.")
      return out
    end
  }
}

---Adds the regex equivalent of a section path/rule expression.
---@param section plugins.editorconfig.parser.section
local function rule_to_regex(section)
  local rule = section.rule.expression

  -- match everything rule which is different from regular *
  -- that doesn't matches path separators
  if rule == "*" then
    section.rule.regex = ".+"
    section.rule.regex_compiled = regex.compile(".+")
    return
  end

  local pos, len, exp = 1, #rule, ""

  -- if expression starts with ! it is treated entirely as a negation
  local negation = rule:match("^%s*!")
  if negation then
    pos = pos + #negation + 1
  end

  -- apply all conversion rules by looping the path expression/rule
  while pos <= len do
    local found = false
    for _, r in ipairs(RULES) do
      local match = rule:match(r.rule, pos)
      if match then
        exp = exp .. r.conversion(match, section)
        pos = pos + #match
        found = true
        break
      end
    end
    if not found then
      exp = exp .. rule:sub(pos, pos)
      pos = pos + 1
    end
  end

  -- store changes to the section rule
  section.rule.regex, section.rule.negation = exp, negation
  section.rule.regex_compiled = regex.compile(section.rule.regex)
  if not section.rule.regex_compiled then
    core.error(
      "[EditorConfig]: could not compile '[%s]' to regex '%s'",
      rule, section.rule.regex
    )
  end
end

---Parses the associated .editorconfig file and stores each section.
function Parser:read()
  local file = io.open(self.config_path, "r")

  self.sections = {}

  if not file then
    core.log("[EditorConfig]: could not read %s", self.config_path)
    return
  end

  ---@type plugins.editorconfig.parser.section
  local section = {}

  for line in file:lines() do
    ---@cast line string

    -- first we try to see if the line is a rule section
    local rule = ""
    rule = line:match("^%s*%[(.-)%]")
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
      rule_to_regex(section)
    end

    if not rule then
      local name, value = line:match("^%s*(%w%S+)%s*=%s*([^%s;#]+)")
      if name and value then
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
        elseif name == "root" then
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
  for i=3, #offsets, 2 do
    local offset_fix = 0
    if i > 1 then offset_fix = 1 end -- workaround for regex offsets bug
    table.insert(result, value:sub(offsets[i], offsets[i+1]-offset_fix))
  end
  return result
end

---Get a matching config for the given filename or nil if nothing found.
---@param file_name string
---@return plugins.editorconfig.parser.section?
function Parser:getConfig(file_name)
  file_name = file_name:gsub("\\", "/")

  local config = {}

  local found = false
  for _, section in ipairs(self.sections) do
    if section.rule.regex_compiled then
      local negation = section.rule.negation
      local matched = {regex.match(section.rule.regex_compiled, file_name)}
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
            if name ~= "rule" then
              config[name] = value
            end
          end
        end
      end
    end
  end

  return found and config or nil
end


return Parser
