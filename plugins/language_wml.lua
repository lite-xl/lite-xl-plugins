-- mod-version:3
local syntax = require "core.syntax"

-- Language syntax references
-- https://wiki.wesnoth.org/SyntaxWML

syntax.add {
  name = "Wesnoth Markup Language",
  files = { "%.w[m|f]l$", "%.cfg$" },
  comment = "%#",
  patterns = {
    { pattern = "%#.*",                                           type = "comment"  }, -- 
    { pattern = { '"', '"', '\\' },                               type = "string"   }, -- 
    { pattern = { "'", "'", '\\' },                               type = "string"   }, -- 
    --{ regex   = "",                               type = "string"   }, -- dice operator
    { pattern = "'\\x%x?%x?%x?%x'",                               type = "string"   }, -- character hexadecimal escape sequence
    { pattern = "'\\u%x%x%x%x'",                                  type = "string"   }, -- character unicode escape sequence
    { pattern = "'\\?.'",                                         type = "string"   }, -- character literal
    { pattern = "-?0x%x+",                                        type = "number"   }, -- 
    { pattern = "-?%d+[%d%.eE]*f?",                               type = "number"   }, -- 
    { pattern = "-?%.?%d+f?",                                     type = "number"   }, -- 
    { pattern = "[%+%-=/%*%^%%<>!~|&]",                           type = "operator" }, -- 
    { pattern = "[%a_][%w_]*%f[(]",                               type = "function" }, -- Function
    { pattern = "[%a_][%w_]*",                                    type = "symbol"   }, -- Symbols
  },
  symbols = {
    ["where"]     = "keyword2",
    [""]     = "keyword2",
    [""]     = "keyword2"
  }
}
