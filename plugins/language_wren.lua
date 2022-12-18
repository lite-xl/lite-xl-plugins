-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Wren",
  files = { "%.wren$" },
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {
    { pattern = "//.-\n",                 type = "comment"  },
    { pattern = { "/%*", "%*/" },         type = "comment"  },
    { pattern = { '"', '"', '\\' },       type = "string"   },
    { pattern = "%d+%.?%d*",              type = "number"   },
    { pattern = "%.%.%.?",                type = "operator" },
    { pattern = "[<>!=]=",                type = "operator" },
    { pattern = "[%+%-=/%*%^%%<>!~|&?:]", type = "operator" },
    { pattern = "__?[%w_]*",              type = "keyword2" },
    { pattern = "%a[%w_]*()%s*%f[(]",     type = {"function", "normal"} },
    { pattern = "%a+",                    type = "symbol"   },
  },
  symbols = {
    ["break"]     = "keyword",
    ["class"]     = "keyword",
    ["construct"] = "keyword",
    ["continue"]  = "keyword",
    ["else"]      = "keyword",
    ["for"]       = "keyword",
    ["foreign"]   = "keyword",
    ["if"]        = "keyword",
    ["import"]    = "keyword",
    ["in"]        = "keyword",
    ["is"]        = "keyword",
    ["return"]    = "keyword",
    ["static"]    = "keyword",
    ["super"]     = "keyword",
    ["var"]       = "keyword",
    ["while"]     = "keyword",
    ["this"]      = "keyword2",
    ["true"]      = "literal",
    ["false"]     = "literal",
    ["null"]      = "literal",
  },
}
