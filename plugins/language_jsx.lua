-- mod-version:3
-- Almost identical to JS, with the exception that / shouldn't denote a regex. Current JS syntax highlighter will highlight half the document due to closing tags.
local syntax = require "core.syntax"

syntax.add {
  name = "JSX",
  files = { "%.jsx$", "%.astro$" },
  comment = "//",
  patterns = {
    { pattern = "//.-\n",               type = "comment"  },
    { pattern = { "/%*", "%*/" },       type = "comment"  },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = { "`", "`", '\\' },     type = "string"   },
    { pattern = "0x[%da-fA-F]+",        type = "number"   },
    { pattern = "-?%d+[%d%.eE]*",       type = "number"   },
    { pattern = "-?%.?%d+",             type = "number"   },
    { pattern = "%f[^<]/?[%a_][%w_]*",  type = "function" },
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
    { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" },
    { pattern = "[%a_][%w_]*",          type = "symbol"   },
  },
  symbols = {
    ["async"]      = "keyword",
    ["await"]      = "keyword",
    ["break"]      = "keyword",
    ["case"]       = "keyword",
    ["catch"]      = "keyword",
    ["class"]      = "keyword",
    ["const"]      = "keyword",
    ["continue"]   = "keyword",
    ["debugger"]   = "keyword",
    ["default"]    = "keyword",
    ["delete"]     = "keyword",
    ["do"]         = "keyword",
    ["else"]       = "keyword",
    ["export"]     = "keyword",
    ["extends"]    = "keyword",
    ["finally"]    = "keyword",
    ["for"]        = "keyword",
    ["from"]       = "keyword",
    ["function"]   = "keyword",
    ["get"]        = "keyword",
    ["if"]         = "keyword",
    ["import"]     = "keyword",
    ["in"]         = "keyword",
    ["instanceof"] = "keyword",
    ["let"]        = "keyword",
    ["new"]        = "keyword",
    ["return"]     = "keyword",
    ["set"]        = "keyword",
    ["static"]     = "keyword",
    ["super"]      = "keyword",
    ["switch"]     = "keyword",
    ["throw"]      = "keyword",
    ["try"]        = "keyword",
    ["typeof"]     = "keyword",
    ["var"]        = "keyword",
    ["void"]       = "keyword",
    ["while"]      = "keyword",
    ["with"]       = "keyword",
    ["yield"]      = "keyword",
    ["true"]       = "literal",
    ["false"]      = "literal",
    ["null"]       = "literal",
    ["undefined"]  = "literal",
    ["arguments"]  = "keyword2",
    ["Infinity"]   = "keyword2",
    ["NaN"]        = "keyword2",
    ["this"]       = "keyword2",
  },
}
