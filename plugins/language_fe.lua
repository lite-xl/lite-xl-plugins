-- mod-version:4
local syntax = require "core.syntax"

syntax.add {
  name = "fe",
  files = "%.fe$",
  comment = ";",
  patterns = {
    { pattern = ";.*",                type = "comment"  },
    { pattern = { '"', '"', '\\' },   type = "string"   },
    { pattern = "0x[%da-fA-F]+",      type = "number"   },
    { pattern = "-?%d+[%d%.]*",       type = "number"   },
    { pattern = "-?%.?%d+",           type = "number"   },
    { pattern = "'",                  type = "symbol"   },
    { pattern = "=",                  type = "symbol"   },
    { pattern = "<=?",                type = "symbol"   },
    { pattern = "[%+-%*/]",           type = "symbol"   },
    { pattern = "%f[^(][^()'%s\"]+",  type = "function" },
    { pattern = "[^()'%s\"]+",        type = "symbol"   },
  },
  symbols = {
    ["let"]    = "keyword",
    ["if"]     = "keyword",
    ["fn"]     = "keyword",
    ["mac"]    = "keyword",
    ["while"]  = "keyword",
    ["quote"]  = "keyword",
    ["'"]      = "keyword",
    ["and"]    = "keyword",
    ["or"]     = "keyword",
    ["do"]     = "keyword",
    ["cons"]   = "keyword",
    ["car"]    = "keyword",
    ["cdr"]    = "keyword",
    ["setcar"] = "keyword",
    ["setcdr"] = "keyword",
    ["list"]   = "keyword",
    ["not"]    = "keyword",
    ["is"]     = "keyword",
    ["atom"]   = "keyword",
    ["print"]  = "keyword",
    ["<"]      = "operator",
    ["<="]     = "operator",
    ["="]      = "operator",
    ["+"]      = "operator",
    ["-"]      = "operator",
    ["*"]      = "operator",
    ["/"]      = "operator",
    ["nil"]    = "literal",
    ["t"]      = "literal",
  }
}
