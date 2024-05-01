-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Vala",
  files = { "%.vala$" },
  comment = "//",
  patterns = {
    { pattern = "//.-\n",                   type = "comment"  },
    { pattern = { '"', '"', '\\' },         type = "string"   },
    { pattern = { "'", "'", '\\' },         type = "string"   },
    { pattern = "-?0x%x+",                  type = "number"   },
    { pattern = "-?%d+[%d%.eE]*f?",         type = "number"   },
    { pattern = "-?%.?%d+f?",               type = "number"   },
    { pattern = "[%+%-=/%*%^%%<>!~|&]",     type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",         type = "function" },
    { pattern = "[%a_][%w_]*",              type = "symbol"   },
  },
  symbols = {
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
    [""] = "keyword",
  },
}
