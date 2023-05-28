-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "GABC",
  files = { "%.gabc$" },
  comment = "%%",
  patterns = {
    { pattern = "%%.*",                 type = "comment"  },
    { pattern = "^%w+:",                type = "keyword2" },
    { pattern = "[%*{}]",               type = "operator" },
    { pattern = "<[^>]*>",              type = "function" },
    { pattern = "-?%.?%d+",             type = "number"   },
    { pattern = { "|", "%)" },          type = "keyword2" },
    { pattern = "%([^%)|]*%)?",         type = "keyword"  },
  },
  symbols = {}
}

