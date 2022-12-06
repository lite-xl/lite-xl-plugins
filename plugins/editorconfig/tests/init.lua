local Parser = require "plugins.editorconfig.parser"

local tests = {}

---@class tests.test
---@field name string Name of test
---@field config string Path to config file
---@field in_match string A path to test against the config
---@field out_match string A regex to match against the result

---Registered tests
---@type tests.test[]
tests.list = {}

--- parsers cache
---@type table<string,plugins.editorconfig.parser>
local parsers = {}
setmetatable(parsers, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      v = Parser.new(k)
      rawset(t, k, v)
    end
    return v
  end
})

---Adds color to given text on non windows systems.
---@param text string
---@param color "red" | "green" | "yellow"
---@return string colorized_text
local function colorize(text, color)
  if PLATFORM ~= "Windows" then
    if color == "green" then
      return "\27[92m"..text.."\27[0m"
    elseif color == "red" then
      return "\27[91m"..text.."\27[0m"
    elseif color == "yellow" then
      return "\27[93m"..text.."\27[0m"
    end
  end
  return text
end

local PASSED = colorize("PASSED", "green")
local FAILED = colorize("FAILED", "red")

---Runs an individual test (executed by tests.run())
---@param name string Test name
---@param config_path string Relative path to tests diretory for a [config].in
---@param in_match string Filename to match
---@param out_match string | table Result to match regex
function tests.check_config(name, config_path, in_match, out_match, pos, total)
  if type(out_match) == "string" then
    out_match = { out_match }
  end
  local parser = parsers[USERDIR .. "/plugins/editorconfig/tests/" .. config_path]
  local config = parser:getConfigString(in_match)
  local passed = true
  for _, match in ipairs(out_match) do
    if not regex.match(match, config) then
      passed = false
      break
    end
  end
  if pos then
    pos = "[" .. pos .. "/" .. total .. "] "
  else
    pos = ""
  end
  if passed then
    print(pos .. string.format("%s - %s - '%s': %s", name, in_match, config_path, PASSED))
  else
    print(pos .. string.format("%s - %s - '%s': %s", name, in_match, config_path, FAILED))
    print(config)
  end
  return passed
end

---Register a new test to be run later.
---@param name string Test name
---@param config_path string Relative path to tests diretory for a [config].in
---@param in_match string Filename to match
---@param out_match string | table Result to match regex
function tests.add(name, config_path, in_match, out_match)
  table.insert(tests.list, {
    name = name,
    config = config_path,
    in_match = in_match,
    out_match = out_match
  })
end

---Runs all registered tests and outputs the results to terminal.
function tests.run()
  print "========================================================="
  print "Running Tests"
  print "========================================================="
  local failed = 0
  local passed = 0
  local total = #tests.list
  for i, test in ipairs(tests.list) do
    local res = tests.check_config(
      test.name, test.config, test.in_match, test.out_match, i, total
    )
    if res then passed = passed + 1 else failed = failed + 1 end
  end
  print "========================================================="
  print (
    string.format(
      "%s %s %s",
      colorize("Total tests: " .. #tests.list, "yellow"),
      colorize("Passed: " .. passed, "green"),
      colorize("Failed: " .. failed, "red")
    )
  )
  print "========================================================="
end

function tests.add_parser(config_path)
  return parsers[config_path]
end

function tests.run_parsers()
  print "========================================================="
  print "Running Parsers"
  print "========================================================="

  for config, parser in pairs(parsers) do
    print "---------------------------------------------------------"
    print(string.format("%s results:", config))
    for _, section in ipairs(parser.sections) do
      print(string.format("\nPath expression: %s", section.rule.expression))
      print(string.format("Regex: %s", section.rule.regex))
      print(string.format("Negation: %s", section.rule.negation and "true" or "false"))
      print(string.format("Ranges: %s\n", section.rule.ranges and #section.rule.ranges or "0"))
    end
    print "---------------------------------------------------------"
  end
end

return tests
