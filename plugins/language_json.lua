-- mod-version:3 priority:90

local syntax = require "core.syntax"

syntax.add {
  name = "JSON",
  files = { "%.json$" },
  comment = nil,
  patterns = {

    { pattern = '\"[a-zA-Z0-9_]*\":', type = "keyword" }, -- key
    { pattern = { '"', '"', "\\"}, type = "string" }, -- value

    -- numbers
    { pattern = "0x[%da-fA-F]+", type = "number" },
    { pattern = "-?%d+[%d%.eE]*",  type = "number" },
    { pattern = "-?%.?%d+", type = "number" },

    -- literals
    { pattern = "null", type = "literal" },
    { pattern = "true", type = "literal" },
    { pattern = "false", type = "literal" }
  },
  symbols = { }
}

