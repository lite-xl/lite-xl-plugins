-- mod-version:3
local syntax = require "core.syntax"

-- monkeyc syntax highlighting for lite(-xl)
-- see https://developer.garmin.com/connect-iq/reference-guides/monkey-c-reference/
-- and language_java.lua

syntax.add {
  name = "MonkeyC",
  files = { "%.mc$", "%.mciq$" },
  comment = "//",
  patterns = {
    { pattern = "//.*",                                           type = "comment"  },
    { pattern = { "/%*", "%*/" },                                 type = "comment"  },
    { pattern = { '"', '"', '\\' },                               type = "string"   },
    { pattern = "-?0x%x+",                                        type = "number"   },
    { pattern = "-?%d+[%d%.eE]*",                                 type = "number"   },
    { pattern = "-?%.?%d+",                                       type = "number"   },
    { pattern = "[%+%-=/%*%^%%<>!~|&]",                           type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",                               type = "function" },
    { regex   = "[A-Z][A-Z_]+",                                   type = "keyword2" },
    { pattern = "[%a_][%w_]*",                                    type = "symbol"   },
  },
  symbols = {
    -- keywords
    ["if"]           = "keyword",
    ["else"]         = "keyword",
    ["while"]        = "keyword",
    ["for"]          = "keyword",
    ["return"]       = "keyword",
    ["break"]        = "keyword",
    ["continue"]     = "keyword",
    ["new"]          = "keyword",
    ["var"]          = "keyword",
    ["class"]        = "keyword",
    ["enum"]         = "keyword",
    ["try"]          = "keyword",
    ["catch"]        = "keyword",
    ["finally"]      = "keyword",
    ["throw"]        = "keyword",
    ["import"]       = "keyword",

    -- types
    ["bool"]         = "keyword2",
    ["char"]         = "keyword2",
    ["double"]       = "keyword2",
    ["float"]        = "keyword2",
    ["int"]          = "keyword2",
    ["long"]         = "keyword2",
    ["string"]       = "keyword2",
    ["object"]       = "keyword2",
    ["bytearray"]    = "keyword2",
    ["array"]        = "keyword2",
    ["dictionary"]   = "keyword2",

    -- literals
    ["true"]         = "literal",
    ["false"]        = "literal",
    ["null"]         = "literal",

    -- operators
    ["+"]            = "operator",
    ["-"]            = "operator",
    ["*"]            = "operator",
    ["/"]            = "operator",
    ["%"]            = "operator",
    ["++"]           = "operator",
    ["--"]           = "operator",
    ["=="]           = "operator",
    ["!="]           = "operator",
    [">"]            = "operator",
    ["<"]            = "operator",
    [">="]           = "operator",
    ["<="]           = "operator",
    ["&&"]           = "operator",
    ["||"]           = "operator",
    ["!"]            = "operator"
  }
}

