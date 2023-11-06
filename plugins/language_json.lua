-- mod-version:3 priority:110

local syntax = require "core.syntax"

syntax.add {
  name = "JSON",
  files = { "%.json$" },
  comment = nil,
  patterns = {
    { pattern = '"[^\n]*"%s*:', type = "keyword" }, -- key
    { pattern = '"[^\n]*"', type = "string" }, -- value
    { pattern = "0x[%da-fA-F]+", type = "number" },
    { pattern = "-?%d+[%d%.eE]*",  type = "number" },
    { pattern = "-?%.?%d+", type = "number" },
    { pattern = "null", type = "literal" },
    { pattern = "true", type = "literal" },
    { pattern = "false", type = "literal" }
  },
  symbols = { }
}

