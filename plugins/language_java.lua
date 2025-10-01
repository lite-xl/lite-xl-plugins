-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax References
-- https://docs.oracle.com/javase/specs/jls/se8/html/index.html

syntax.add {
  name = "Java",
  files = { "%.java$" },
  comment = "//",
  patterns = {
    { pattern = "//.*",                             type = "comment"  }, -- Single-line comment
    { pattern = { "/%*", "%*/" },                   type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                 type = "string"   }, -- String
    { pattern = { "'", "'", '\\' },                 type = "string"   }, -- String
    { pattern = "'\\x%x?%x?%x?%x'",                 type = "string"   }, -- character hexadecimal escape sequence
    { pattern = "'\\u%x%x%x%x'",                    type = "string"   }, -- character unicode escape sequence
    { pattern = "'\\?.'",                           type = "string"   }, -- character literal
    { pattern = "-?0x%x+",                          type = "number"   }, -- Number: hexadecimal
    { pattern = "-?%d+[%d%.eE]*[fFdD]?",            type = "number"   }, -- Number: exponential, float/double
    { pattern = "%<.-%>%>*",                        type = "keyword2" }, -- Generic
    { pattern = "[%+%-=/%*%^%%<>!~|&]",             type = "operator" }, -- Operator
    { pattern = "[%a_][%w_]*%f[(]",                 type = "function" }, -- Method
    { pattern = "^import()%s+()[%w_.]+",            type = { "keyword", "normal", "normal" } }, -- Import
    { pattern = "[A-Z][A-Z_%d]+%f[^a-zA-Z_%d]",     type = "keyword2" }, -- Constants
    { pattern = "this()%s*.*$",                     type = { "keyword", "normal" } }, -- FIX: ?
    { pattern = "%@%w+",                            type = "keyword2" }, -- Annotation
    { pattern = "%:%:()%w+",                        type = { "normal", "function" } }, -- Method reference with double colon operator
    { pattern = "%.class",                          type = "normal"   }, -- .class should be colored as normal
    { pattern = "[%a_][%w_]*",                      type = "symbol"   } -- Symbols
  },
  symbols = {
    ["abstract"]      = "keyword",
    ["assert"]        = "keyword",
    ["break"]         = "keyword",
    ["case"]          = "keyword",
    ["catch"]         = "keyword",
    ["class"]         = "keyword",
    ["const"]         = "keyword",
    ["continue"]      = "keyword",
    ["default"]       = "keyword",
    ["do"]            = "keyword",
    ["else"]          = "keyword",
    ["enum"]          = "keyword",
    ["extends"]       = "keyword",
    ["final"]         = "keyword",
    ["finally"]       = "keyword",
    ["for"]           = "keyword",
    ["if"]            = "keyword",
    ["goto"]          = "keyword",
    ["implements"]    = "keyword",
    ["import"]        = "keyword",
    ["instanceof"]    = "keyword",
    ["interface"]     = "keyword",
    ["native"]        = "keyword",
    ["new"]           = "keyword",
    ["package"]       = "keyword",
    ["permits"]       = "keyword",
    ["private"]       = "keyword",
    ["protected"]     = "keyword",
    ["public"]        = "keyword",
    ["record"]        = "keyword",
    ["return"]        = "keyword",
    ["sealed"]        = "keyword",
    ["static"]        = "keyword",
    ["strictfp"]      = "keyword",
    ["super"]         = "keyword",
    ["switch"]        = "keyword",
    ["synchronized"]  = "keyword",
    ["this"]          = "keyword",
    ["throw"]         = "keyword",
    ["throws"]        = "keyword",
    ["transient"]     = "keyword",
    ["try"]           = "keyword",
    ["var"]           = "keyword",
    ["void"]          = "keyword",
    ["volatile"]      = "keyword",
    ["while"]         = "keyword",
    ["yield"]         = "keyword",

    ["boolean"]       = "keyword",
    ["byte"]          = "keyword",
    ["char"]          = "keyword",
    ["double"]        = "keyword",
    ["float"]         = "keyword",
    ["int"]           = "keyword",
    ["long"]          = "keyword",
    ["short"]         = "keyword",

    ["true"]          = "literal",
    ["false"]         = "literal",
    ["null"]          = "literal"
  }
}
