-- mod-version:3

-- to better understand these comments, see this section from rxi's article
-- https://rxi.github.io/lite_an_implementation_overview.html#syntax_highlighting

-- first, we need to require the syntax module
local syntax = require "core.syntax"

--[[
  then, we'll add a new syntax to the syntax module, lite-xl matches Lua patterns
  against the source code in order to highlight the code.
]]
syntax.add {
  -- the extension of source code
  files = "%.nelua$",
  -- this add support for shebang, is not rare to add #!/usr/local/bin/lua to make
  -- lua scripts executable, here we add support for it for nelua
  headers = "^#!.*[ /]nelua",
  -- tells to lite how to toggle comments
  comment = "--",
  -- finally the patterns, is a table of tables,
  -- each entry is a table with some fields, especially with "pattern" and "type" fields.
  patterns = {
    --[[
      ["pattern"] field:
      Describes a syntax pattern, this is done with Lua Patterns
      you can learn it works here: https://www.lua.org/manual/5.4/manual.html#6.4.1

      The pattern can be a string or a table, when is a string, then is just a
      pattern that match everything, when is a table, then it follows this
      logic:
      { range_start_pattern, range_end_pattern [, escape_character] }

      The matched range_start_pattern and range_end_pattern text will be highlighted, but the
      text between them will not.

      ["syntax"] field:
      Optional field, when set, the text between matched ranges will use syntax from another language,
      a good common known example of this is using javascript syntax inside a `script` element:
      https://github.com/lite-xl/lite-xl/blob/df667ad28e9995f8cb79dab64e6039f095c202f4/data/plugins/language_html.lua#L17-L23

      ["type"] field:
      Set the style that should be used, this is defined on the "style" file from
      the lite-xl's source, at "data/core/style.lua".
    ]]
    {
      pattern = {"##%[=*%[", "%]=*%]"},
      syntax = ".lua",
      type = "function",
    },
    {
      pattern = {"#|", "|#"},
      syntax = ".lua",
      type = "function",
    },
    {
      pattern = {"##", "\n"},
      syntax = ".lua",
      type = "function",
    },
    { pattern = { '"', '"', '\\' },           type = "string" },
    { pattern = { "'", "'", '\\' },           type = "string" },
    { pattern = { "%[%[", "%]%]" },           type = "string" },
    { pattern = { "%-%-%[=*%[", "%]=*%]"},    type = "comment" },
    { pattern = "%-%-.-\n",                   type = "comment" },
    { pattern = "0x%x+%.%x*[pP][-+]?%d+",     type = "number" },
    { pattern = "0x%x+%.%x*",                 type = "number" },
    { pattern = "0x%.%x+[pP][-+]?%d+",        type = "number" },
    { pattern = "0x%.%x+",                    type = "number" },
    { pattern = "0x%x+[pP][-+]?%d+",          type = "number" },
    { pattern = "0x%x+",                      type = "number" },
    { pattern = "%d%.%d*[eE][-+]?%d+",        type = "number" },
    { pattern = "%d%.%d*",                    type = "number" },
    { pattern = "%.?%d*[eE][-+]?%d+",         type = "number" },
    { pattern = "<%S[%w+%._,%s*'\"()<>]-%S>", type = "keyword2" },
    { pattern = "%.?%d+",                     type = "number" },
    { pattern = "%.%.%.?",                    type = "operator" },
    { pattern = "[<>~=]=",                    type = "operator" },
    { pattern = "[%+%-=/%*%^%%#<>]",          type = "operator" },
    { pattern = "[%a_][%w_]*()%s*%f[(\"'{]",  type = {"function", "normal"} },
    { pattern = "[%a_][%w_]*",                type = "symbol" },
    { pattern = "::[%a_][%w_]*::",            type = "function" },
  },
  -- special symbols, like keywords
  symbols = {
    -- lua symbols
    ["if"]       = "keyword",
    ["then"]     = "keyword",
    ["else"]     = "keyword",
    ["elseif"]   = "keyword",
    ["end"]      = "keyword",
    ["do"]       = "keyword",
    ["function"] = "keyword",
    ["repeat"]   = "keyword",
    ["until"]    = "keyword",
    ["while"]    = "keyword",
    ["for"]      = "keyword",
    ["break"]    = "keyword",
    ["return"]   = "keyword",
    ["local"]    = "keyword",
    ["in"]       = "keyword",
    ["not"]      = "keyword",
    ["and"]      = "keyword",
    ["or"]       = "keyword",
    ["goto"]     = "keyword",
    ["self"]     = "keyword2",
    ["true"]     = "literal",
    ["false"]    = "literal",
    ["nil"]      = "literal",

    -- nelua symbols
    ["global"]   = "keyword",
    ["switch"]   = "keyword",
    ["case"]     = "keyword",
    ["defer"]    = "keyword",
    ["continue"] = "keyword",
    ["nilptr"]   = "keyword",
  },
}
