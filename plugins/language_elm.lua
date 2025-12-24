-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Elm",
  files = { "%.elm$" },
  comment = "%-%-",
  patterns = {
    { pattern = {"%-%-", "\n"},                       type = "comment"  }, -- Single-line comment
    { pattern = { "{%-", "%-}" },                     type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                   type = "string"   }, -- Single-line string
    { pattern = { '"""', '"""', '\\' },               type = "string"   }, -- Multi-line string
    { pattern = { "'", "'", '\\' },                   type = "string"   }, -- Single-line string, apices
    { pattern = "-?0x%x+",                            type = "number"   }, -- ?
    { pattern = "-?%d+[%d%.eE]*f?",                   type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",                         type = "number"   }, -- ?
    { pattern = "%.%.",                               type = "operator" }, -- ?
    { pattern = "[=:|&<>%+%-%*\\/%^%%]",              type = "operator" }, -- Operators
    { pattern = "^[a-zA-Z0-0_]+",                     type = "function" }, -- Function definition
    -- TODO: verify that the following 2 patterns are actually function calls and not data structure definitions
    { pattern = '[a-zA-Z0-0_]+()%s()%f[%"]',          type = { "function", "normal", "symbol"} },
    { pattern = '[a-zA-Z0-0_]+()%s()%f[%[]',          type = { "function", "normal", "symbol"} },
    -- WIP: Function definition
    { pattern = '[a-zA-Z0-0_]+()%s()%f[%=]',          type = { "function", "normal", "symbol"} },
    -- WIP: Function call
    { pattern = '[a-zA-Z0-0_]+()%s()%f[a-zA-z0-9]',   type = { "function", "normal", "symbol" } },
    { pattern = "[%a_'][%w_']*",                      type = "symbol"   } -- Symbols
  },
  symbols = {
    ["as"] = "keyword",
    ["case"] = "keyword",
    ["of"] = "keyword",
    ["if"] = "keyword",
    ["then"] = "keyword",
    ["else"] = "keyword",
    ["import"] = "keyword",
    ["module"] = "keyword",
    ["exposing"] = "keyword",
    ["let"] = "keyword",
    ["in"] = "keyword",
    ["type"] = "keyword",
    ["alias"] = "keyword",
    ["port"] = "keyword",
    ["and"] = "keyword",
    ["or"] = "keyword",
    ["xor"] = "keyword",
    ["not"] = "keyword",
    ["number"] = "keyword2",
    ["Bool"] = "keyword2",
    ["Char"] = "keyword2",
    ["Float"] = "keyword2",
    ["Int"] = "keyword2",
    ["String"] = "keyword2",
    ["True"] = "literal",
    ["False"] = "literal",
  },
}
