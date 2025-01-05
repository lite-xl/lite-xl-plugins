-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "CUE",
  files = "%.cue$",
  comment = "//",
  patterns = {
    { pattern = "//.*",                      type = "comment" },
    { pattern = { '"', '"', '\\' },          type = "string" },
    { pattern = { "`", "`", '\\' },          type = "string" },
    { pattern = { "'", "'", '\\' },          type = "string" },
    { pattern = "0[oO_][0-7]+i?",            type = "number" },
    { pattern = "-?0x[%x_]+i?",              type = "number" },
    { pattern = "-?%d+_%di?",                type = "number" },
    { pattern = "-?%d+[%d%.eE]*f?i?",        type = "number" },
    { pattern = "-?%.?%d+f?i?",              type = "number" },
    { pattern = "[%a_][%w_]*%.",             type = "literal" },
    { pattern = "[%a_][%w_]*",               type = "symbol" },
    { pattern = "#[%a][%w_]*",               type = "keyword2" },
    -- operators
    { pattern = "[%+%-=/%*%^%%<>!~|&%?:%.]", type = "operator" },
  },
  symbols = {
    ["package"] = "keyword",
    ["import"]  = "keyword",
    ["let"]     = "keyword",
    ["for"]     = "keyword",
    ["true"]    = "literal",
    ["false"]   = "literal",
    ["string"]  = "keyword2",
    ["bool"]    = "keyword2",
    ["number"]  = "keyword2",
    ["uint32"]  = "keyword2",
    ["int32"]   = "keyword2",
    ["uint16"]  = "keyword2",
    ["int16"]   = "keyword2",
    ["uint8"]   = "keyword2",
    ["float"]   = "keyword2",
  }
}
