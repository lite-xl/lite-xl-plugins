-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax Reference
-- https://plantuml.com/

syntax.add {
  name = "PlantUML",
  files = { "%.puml$", "%.plantuml$", "%.pu$", "%.iuml$", "%.wsd$" },
  comment = "/'",
  block_comment = { "/'", "'/" },
  patterns = {
    { pattern = "^%'.*$",                                type = "comment" }, -- Single-line comment
    { pattern = { "^/'", "%'%/" } ,                      type = "comment" }, -- Multi-line comment
    { pattern = "^%@%w+",                                type = "keyword2" }, -- start... end...
    { pattern = "",                                      type = "operator" }, -- Operators
    { pattern = "[%a_][%w_]*",                           type = "symbol"   }, -- Everything else
  },
  symbols = {
    ["true"] = "literal",
    ["false"] = "literal",
  }
}
