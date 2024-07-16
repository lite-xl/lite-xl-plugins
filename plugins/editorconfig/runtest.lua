local core = require "core"
local tests = require "plugins.editorconfig.tests"

-- disable print buffer for immediate output
io.stdout:setvbuf "no"

-- overwrite to print into stdout
function core.error(format, ...)
  print(string.format(format, ...))
end

function core.log(format, ...)
  print(string.format(format, ...))
end

function core.log_quiet(format, ...)
  print(string.format(format, ...))
end

-- check if --parsers flag was given to only output the path expressions and
-- their conversion into regular expressions.
local PARSERS = false
for _, argument in ipairs(ARGS) do
  if argument == "--parsers" then
    PARSERS = true
  end
end

if not PARSERS then
  require "plugins.editorconfig.tests.glob"
  require "plugins.editorconfig.tests.parser"
  require "plugins.editorconfig.tests.properties"

  tests.run()
else
  -- Globs
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/glob/braces.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/glob/brackets.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/glob/question.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/glob/star.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/glob/star_star.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/glob/utf8char.in")

  -- Parser
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/basic.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/bom.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/comments.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/comments_and_newlines.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/comments_only.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/crlf.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/empty.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/limits.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/newlines_only.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/parser/whitespace.in")

  -- Properties
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/properties/indent_size_default.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/properties/lowercase_names.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/properties/lowercase_values.in")
  tests.add_parser(USERDIR .. "/plugins/editorconfig/tests/properties/tab_width_default.in")

  tests.run_parsers()
end
