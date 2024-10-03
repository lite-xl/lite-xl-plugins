-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
  name = "TOML",
  files = { "%.toml$" },
  comment = '#',

  patterns = {
    { pattern = "#.*",                                type = "comment"  },

    { pattern = { '"""', '"""', '\\' },               type = "string"   },
    { pattern = { "'''", "'''"       },               type = "string"   },
    { pattern = { '"',   '"',   '\\' },               type = "string"   },
    { pattern = { "'",   "'"         },               type = "string"   },

    { pattern = "[%w_%.%-]+%s*%f[=]",                 type = "function" },

    { pattern = {"^%s*%[", "%]"},                     type = "keyword"  },

    { pattern = "0x[%x_]+",                           type = "number"   },
    { pattern = "0o[0-7_]+",                          type = "number"   },
    { pattern = "0b[01_]+",                           type = "number"   },
    { pattern = "%d[%d_]*%.?[%d_]*[eE][%-+]?[%d_]+",  type = "number"   },
    { pattern = "%d[%d_]*%.?[$d_]*",                  type = "number"   },
    { pattern = "%f[-+%w_][-+]%f[%w%.]",              type = "number"   },

    { pattern = "[%+%-:TZ]",                          type = "operator" },
    { pattern = "%a+",                                type = "symbol"   },
  },

  symbols = {
    ["true"] = "literal",
    ["false"] = "literal",

    ["nan"]  = "number",
    ["inf"]  = "number"
  },
}
