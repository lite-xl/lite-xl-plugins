-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax Reference
-- https://plantuml.com/

syntax.add {
  name = "Plantuml",
  -- FIX: //... and /*...*/ are wrong!
  files = "%.puml$",
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {
    { pattern = "^%@%w+", type = "keyword" }, -- ?
    --{ pattern = "", type = "" }, -- ?
    -- FIX: match plantuml operators (es. -->, <--)
    { pattern = "[%+%-=/%*%^%%<>!~|&%?%:]",      type = "operator" }, -- Operators
    { pattern = "[%a_][%w_]*",                 type = "symbol"   } -- Everything else
  },
  symbols = {
    ["true"] = "literal",
  }
}
