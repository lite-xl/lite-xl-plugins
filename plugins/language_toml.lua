-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
  name = "TOML",
  files = { "%.toml$" },
  comment = '#',
  patterns = {
    { pattern = "#.-\n", type = "comment" },
    { pattern = { '"""', '"""', '\\' }, type = "string" },
    { pattern = { '"', '"', '\\' }, type = "string" },
    { pattern = { "'''", "'''" }, type = "string" },
    { pattern = { "'", "'" }, type = "string" },
    { pattern = "[A-Za-z0-9_%.%-]+%s*%f[=]", type = "function" },
    { pattern = "%[[A-Za-z0-9_%.%- ]+%]", type = "keyword" },
    { pattern = "%[%[[A-Za-z0-9_%.%- ]+%]%]", type = "keyword" },
    { pattern = "[%-+]?[0-9_]+%.[0-9_]+[eE][%-+]?[0-9_]+", type = "number" },
    { pattern = "[%-+]?[0-9_]+%.[0-9_]+", type = "number" },
    { pattern = "[%-+]?[0-9_]+[eE][%-+]?[0-9_]+", type = "number" },
    { pattern = "[%-+]?[0-9_]+", type = "number" },
    { pattern = "[%-+]?0x[0-9a-fA-F_]+", type = "number" },
    { pattern = "[%-+]?0o[0-7_]+", type = "number" },
    { pattern = "[%-+]?0b[01_]+", type = "number" },
    { pattern = "[%-+]?nan", type = "number" },
    { pattern = "[%-+]?inf", type = "number" },
    { pattern = "[a-z]+", type = "symbol" },
  },
  symbols = {
    ["true"] = "literal",
    ["false"] = "literal",
  },
}
