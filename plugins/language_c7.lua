-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "cel7",
  files = "%.c7$",
  comment = ";",
  patterns = {
    { pattern = ";.-\n",              type = "comment"  },
    { pattern = { '"', '"', '\\' },   type = "string"   },
    { pattern = "0x4000",             type = "literal"  },
    { pattern = "0x4040",             type = "literal"  },
    { pattern = "0x52a0",             type = "literal"  },
    { pattern = "0x[%da-fA-F]+",      type = "number"   },
    { pattern = "-?%d+[%d%.]*",       type = "number"   },
    { pattern = "-?%.?%d+",           type = "number"   },
    { pattern = "'",                  type = "symbol"   },
    { pattern = "=",                  type = "symbol"   },
    { pattern = "<=?",                type = "symbol"   },
    { pattern = "[%+-%*/]",           type = "symbol"   },
    { pattern = "//",                 type = "keyword2" },
    { pattern = "%%",                 type = "keyword2" },
    { pattern = "%f[^(][^()'%s\"]+",  type = "function" },
    { pattern = "[^()'%s\"]+",        type = "symbol"   },
  },
  symbols = {
    ["let"]    = "keyword",
    ["="]      = "operator",
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

    -- reserved variables (config)
    ["title"]  = "keyword2",
    ["width"]  = "keyword2",
    ["height"] = "keyword2",
    ["debug"]  = "keyword2",

    -- callbacks
    ["init"]    = "keyword2",
    ["step"]    = "keyword2",
    ["keydown"] = "keyword2",
    ["keyup"]   = "keyword2",

    -- built-in functions
    ["quit"]  = "keyword2",
    ["rand"]  = "keyword2",
    ["poke"]  = "keyword2",
    ["peek"]  = "keyword2",
    ["color"] = "keyword2",
    ["put"]   = "keyword2",
    ["get"]   = "keyword2",
    ["fill"]  = "keyword2",
  }
}
