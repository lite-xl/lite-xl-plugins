-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
  name = "FAR LNG",
  files = "%.lng$",
  comment = ";",
  patterns = {
    { pattern = ";.*", type = "comment" },
    { pattern = { '"', '"', '\\' }, type = "string" },
    { pattern = "[A-Za-z0-9_%.%-]+%s*%f[=]", type = "function" }, -- key
    { pattern = "=", type = "operator" },
  },
  symbols = {},
}