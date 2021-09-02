-- mod-version:2 -- lite-xl 2.0
--[[
  language_php.lua
  provides php syntax support allowing mixed html, css and js
  version: 20210902_1
--]]
local syntax = require "core.syntax"

-- load syntax dependencies to add additional rules
require "plugins.language_css"
require "plugins.language_js"

-- define the core php syntax coloring
syntax.add {
  files = { "%.phps$" },
  headers = "^<%?php",
  comment = "//",
  patterns = {
    -- Attributes
    { pattern = {"#%[", "%]"},               type = "normal"   },
    -- Comments
    { pattern = "//.-\n",                    type = "comment"  },
    { pattern = "#.-\n",                     type = "comment"  },
    { pattern = { "/%*", "%*/" },            type = "comment"  },
    -- The '\\' is for escaping to work on " or '
    { pattern = { '"', '"', '\\' },          type = "string"   },
    { pattern = { "'", "'", '\\' },          type = "string"   },
    { pattern = "0[bB][%d]+",                type = "number"   },
    { pattern = "0[xX][%da-fA-F]+",          type = "number"   },
    { pattern = "-?%d[%d_%.eE]*",            type = "number"   },
    { pattern = "-?%.?%d+",                  type = "number"   },
    { pattern = "[%.%+%-=/%*%^%%<>!~|&%?:]", type = "operator" },
     -- Variables
    { pattern = "%$[%w_]+",                  type = "keyword2" },
    -- Respect control structures, treat as keyword not function
    { pattern = "if[%s]*%f[(]",              type = "keyword"  },
    { pattern = "else[%s]*%f[(]",            type = "keyword"  },
    { pattern = "elseif[%s]*%f[(]",          type = "keyword"  },
    { pattern = "for[%s]*%f[(]",             type = "keyword"  },
    { pattern = "foreach[%s]*%f[(]",         type = "keyword"  },
    { pattern = "while[%s]*%f[(]",           type = "keyword"  },
    { pattern = "catch[%s]*%f[(]",           type = "keyword"  },
    { pattern = "switch[%s]*%f[(]",          type = "keyword"  },
    { pattern = "match[%s]*%f[(]",           type = "keyword"  },
    { pattern = "fn[%s]*%f[(]",              type = "keyword"  },
    -- All functions that aren't control structures
    { pattern = "[%a_][%w_]*[%s]*%f[(]",     type = "function" },
    -- Array type hint not added on symbols to also make it work
    -- as a function call
    { pattern = "array",                     type = "literal"  },
    -- Match static or namespace container on sub element access
    { pattern = "[%a_][%w_]*[%s]*%f[:]",     type = "literal"  },
    -- Uppercase constants of at least 3 characters in len
    { pattern = "%u[%u_][%u%d_]+",           type = "number"   },
    -- Magic constants
    { pattern = "__[%u]+__",                 type = "number"   },
    -- Everything else
    { pattern = "[%a_][%w_]*",               type = "symbol"   },
  },
  symbols = {
    ["return"] = "keyword",
    ["if"] = "keyword",
    ["else"] = "keyword",
    ["elseif"] = "keyword",
    ["endif"] = "keyword",
    ["declare"] = "keyword",
    ["enddeclare"] = "keyword",
    ["switch"] = "keyword",
    ["endswitch"] = "keyword",
    ["as"] = "keyword",
    ["do"] = "keyword",
    ["for"] = "keyword",
    ["endfor"] = "keyword",
    ["foreach"] = "keyword",
    ["endforeach"] = "keyword",
    ["while"] = "keyword",
    ["endwhile"] = "keyword",
    ["match"] = "keyword",
    ["case"] = "keyword",
    ["continue"] = "keyword",
    ["default"] = "keyword",
    ["break"] = "keyword",
    ["goto"] = "keyword",

    ["try"] = "keyword",
    ["catch"] = "keyword",
    ["throw"] = "keyword",
    ["finally"] = "keyword",

    ["class"] = "keyword",
    ["trait"] = "keyword",
    ["interface"] = "keyword",
    ["public"] = "keyword",
    ["static"] = "keyword",
    ["protected"] = "keyword",
    ["private"] = "keyword",
    ["abstract"] = "keyword",
    ["final"] = "keyword",
    ["$this"] = "literal",

    ["function"] = "keyword",
    ["fn"] = "keyword",
    ["global"] = "keyword",
    ["var"] = "keyword",
    ["const"] = "keyword",

    ["bool"] = "literal",
    ["boolean"] = "literal",
    ["int"] = "literal",
    ["integer"] = "literal",
    ["real"] = "literal",
    ["double"] = "literal",
    ["float"] = "literal",
    ["string"] = "literal",
    ["object"] = "literal",
    ["callable"] = "literal",
    ["iterable"] = "literal",
    ["void"] = "literal",
    ["parent"] = "literal",
    ["self"] = "literal",
    ["mixed"] = "literal",

    ["namespace"] = "keyword",
    ["extends"] = "keyword",
    ["implements"] = "keyword",
    ["instanceof"] = "keyword",
    ["require"] = "keyword",
    ["require_once"] = "keyword",
    ["include"] = "keyword",
    ["include_once"] = "keyword",
    ["use"] = "keyword",
    ["new"] = "keyword",
    ["clone"] = "keyword",

    ["true"] = "number",
    ["false"] = "number",
    ["NULL"] = "number",
    ["null"] = "number",

    ["print"] = "function",
    ["echo"] = "function",
    ["exit"] = "function",
  },
}

-- allows html, css and js coloring on php files
syntax.add {
  files = { "%.php$", "%.phtml" },
  patterns = {
    {
      pattern = {
        "<%?php%s+",
        "%?>"
      },
      syntax = ".phps",
      type = "keyword2"
    },
    {
      pattern = {
        "<%?=?",
        "%?>"
      },
      syntax = ".phps",
      type = "keyword2"
    },
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%s+[tT][yY][pP][eE]%s*=%s*" ..
          "['\"]%a+/[jJ][aA][vV][aA][sS][cC][rR][iI][pP][tT]['\"]%s*>",
        "<%s*/[sS][cC][rR][iI][pP][tT]>"
      },
      syntax = ".js",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%s*>",
        "<%s*/%s*[sS][cC][rR][iI][pP][tT]>"
      },
      syntax = ".js",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][tT][yY][lL][eE][^>]*>",
        "<%s*/%s*[sS][tT][yY][lL][eE]%s*>"
      },
      syntax = ".css",
      type = "function"
    },
    { pattern = { "<!%-%-", "%-%->" },     type = "comment"  },
    { pattern = { '%f[^>][^<]', '%f[<]' }, type = "normal"   },
    { pattern = { '"', '"', '\\' },        type = "string"   },
    { pattern = { "'", "'", '\\' },        type = "string"   },
    { pattern = "0x[%da-fA-F]+",           type = "number"   },
    { pattern = "-?%d+[%d%.]*f?",          type = "number"   },
    { pattern = "-?%.?%d+f?",              type = "number"   },
    { pattern = "%f[^<]![%a_][%w_]*",      type = "keyword2" },
    { pattern = "%f[^<][%a_][%w_]*",       type = "function" },
    { pattern = "%f[^<]/[%a_][%w_]*",      type = "function" },
    { pattern = "[%a_][%w_]*",             type = "keyword"  },
    { pattern = "[/<>=]",                  type = "operator" },
  },
  symbols = {},
}

-- allow coloring of php code inside css and js code
local syntaxes = { "css", "js" }
for _, ext in pairs(syntaxes) do
  local syntax_table = syntax.get("file."..ext, "")

  table.insert(
    syntax_table.patterns,
    1,
    {
      pattern = {
        "<%?=?",
        "%?>"
      },
      syntax = ".phps",
      type = "keyword2"
    }
  )

  table.insert(
    syntax_table.patterns,
    1,
    {
      pattern = {
        "<%?php%s+",
        "%?>"
      },
      syntax = ".phps",
      type = "keyword2"
    }
  )
end
