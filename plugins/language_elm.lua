-- mod-version:4
local syntax = require "core.syntax"

syntax.add {
  name = "Elm",
  files = { "%.elm$" },
  comment = "%-%-",
  patterns = {
    { pattern = {"%-%-", "\n"},          type = "comment"  },
    { pattern = { "{%-", "%-}" },        type = "comment"  },
    { pattern = { '"', '"', '\\' },      type = "string"   },
    { pattern = { '"""', '"""', '\\' },  type = "string"   },
    { pattern = { "'", "'", '\\' },      type = "string"   },
    { pattern = "-?0x%x+",               type = "number"   },
    { pattern = "-?%d+[%d%.eE]*f?",      type = "number"   },
    { pattern = "-?%.?%d+f?",            type = "number"   },
    { pattern = "%.%.",                  type = "operator" },
    { pattern = "[=:|&<>%+%-%*\\/%^%%]", type = "operator" },
    { pattern = "[%a_'][%w_']*",         type = "symbol"   },
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
