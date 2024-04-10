-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "FSharp",
  files = { "%.fs$" },
  comment = "//",
  patterns = {
    { pattern = "//.-\n",                   type = "comment"  },
  },
  symbols = {
    -- Common
    ["shared"]     = "keyword",
  },
}
