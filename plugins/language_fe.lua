-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

syntax.add {
  files = "%.fe$",
  comment = ";",
  patterns = {
    { pattern = ";.-\n",              type = "comment"  },
    { pattern = { '"', '"', '\\' },   type = "string"   },
    { pattern = "0x[%da-fA-F]+",      type = "number"   },
    { pattern = "-?%d+[%d%.]*",       type = "number"   },
    { pattern = "-?%.?%d+",           type = "number"   },
    { pattern = "'",                  type = "symbol"  },
    { pattern = "%f[^(][^()'%s\"]+",  type = "function" },
    { pattern = "[^()'%s\"]+",        type = "symbol"   },
  },
  symbols = {
    ["if"]     = "keyword2",
    ["let"]    = "keyword2",
    ["do"]     = "keyword2",
    ["fn"]     = "keyword2",
    ["mac"]    = "keyword2",
    ["'"]      = "keyword2",
    ["print"]  = "keyword",
    ["while"]  = "keyword",
    ["car"]    = "keyword",
    ["cdr"]    = "keyword",
    ["not"]    = "keyword",
    ["setcdr"] = "keyword",
    ["setcar"] = "keyword",
    ["nil"]    = "literal",
    ["t"]      = "literal",
  }
}
