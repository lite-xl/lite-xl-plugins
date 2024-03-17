-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "OpenSCAD",
  files = {"%.scad$"},
  comment = "//",
  patterns = {},
  symbols = {
    -- Shapes
    ["cube"] = "",
    ["sphere"] = "",
    -- Trasformations
    ["translate"] = "",
    -- Other
    ["module"] = "",
    ["function"] = "function",
  }
}
