-- mod-version:3
local syntax = require "core.syntax"

-- Language syntax reference
-- https://gnome.pages.gitlab.gnome.org/vala/manual/overview.html

-- https://devina.io/redos-checker
-- https://redosdetector.com/?pattern=%5C%40%3F%5C%22&caseInsensitive=false&unicode=false

syntax.add {
  name = "Vala",
  files = { "%.vala$" },
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    { pattern = "//.*",                                                                    type = "comment"  }, -- Single-line comment
    { pattern = { "/%*", "%*/" },                                                          type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                                                        type = "string"   }, -- String, double apices
    { regex   = { '\\@?\\"', '\\"', '\\' },                                                type = "string"   }, -- Special string
    { pattern = { "'", "'", '\\' },                                                        type = "string"   }, -- String, apices
    { pattern = "-?0x%x+",                                                                 type = "number"   }, -- Numbers
    -- FIX: Vulnerable to REDO
    { regex   = "-?(?:\\d_?)+(?:.\\d+[eE]?)?f?",                                           type = "number"   }, -- Numbers
    -- ?
    { regex   = "\\w+(?=(?:\\s+\\w++\\s+\\=\\s+)|(?:\\s+\\w+\\s*[)]))",                    type = "function" }, -- Class name in class instance
    -- FIX: Vulnerable to REDO
    { regex   = "\\<(?:[\\w+][\\<\\w+\\>]\\,?\\s*)+\\>(?=[(]?[)]?[\\;\\s*])",              type = "keyword2" }, -- Generic Type
    { pattern = "[%+%-=/%*%^%%<>!~|&]",                                                    type = "operator" }, -- Operators
    { pattern = "[%a_][%w_]*%f[(]",                                                        type = "function" }, -- Function
    -- FIX: Vulnerable to REDO
    { regex   = [[\s?\:\s?(?:\w+\.?)+(?=\s?[{])]],                                         type = "keyword2" }, -- Inheritance
    -- FIX: Vulnerable to REDO
    { regex   = [[\s?\:\s?(?:\w+(?:\.\w+)?(?:\<\w+\.\w+\>)?\s?\,?\s?)+(?=\s?[{])]],        type = "keyword2" }, -- Inheritance
    -- FIX: Vulnerable to REDO
    { regex   = [[class()\s+\w+()\<.+\>(?=\s?\:)]],                                        type = { "keyword", "normal", "keyword2" } }, -- Generic Class Type
    -- FIX: Vulnerable to REDO
    { regex   = [[interface()\s+\w+()\<.+\>(?=\s?\:)]],                                    type = { "keyword", "normal", "keyword2" } }, -- Generic Interface Type
    { regex   = "\\=\\>(?=[{])",                                                           type = "keyword"  }, -- Lambda
    -- FIX: Vulnerable to REDO
    { regex   = "[A-Z][A-Z_]+(?=\\s*[)]|[\\;]|[\\,]|[\\s\\=])",                            type = "keyword2" }, -- Constants
    { regex   = "^\\[.+\\]",                                                               type = "literal"  }, -- Attribute
    { regex   = "\\#\\w+(?=\\s?\\w*)",                                                     type = "keyword"  }, -- Preprocessor directive
    { pattern = "[%a_][%w_]*",                                                             type = "symbol"   }, -- Symbols
  },
  symbols = {
    ["class"] = "keyword",
    ["this"] = "keyword",
    ["is"] = "keyword",
    ["as"] = "keyword",
    ["var"] = "keyword",
    ["const"] = "keyword",
    ["new"] = "keyword",
    ["enum"] = "keyword",
    ["namespace"] = "keyword",
    ["interface"] = "keyword",
    ["construct"] = "keyword",
    ["virtual"] = "keyword",
    ["get"] = "keyword",
    ["set"] = "keyword",
    ["default"] = "keyword",
    ["signal"] = "keyword",
    ["struct"] = "keyword",
    ["Type"] = "keyword",
    ["string"] = "keyword",
    ["yield"] = "keyword",
    ["owned"] = "keyword",
    ["unowned"] = "keyword",
    ["weak"] = "keyword",
    
    ["public"] = "keyword",
    ["private"] = "keyword",
    ["protected"] = "keyword",
    ["internal"] = "keyword",
    ["static"] = "keyword",
    ["void"] = "keyword",
    ["override"] = "keyword",
    ["abstract"] = "keyword",
    
    ["if"] = "keyword",
    ["else"] = "keyword",
    ["elseif"] = "keyword",
    ["for"] = "keyword",
    ["foreach"] = "keyword",
    ["while"] = "keyword",
    ["do"] = "keyword",
    ["break"] = "keyword",
    ["continue"] = "keyword",
    ["return"] = "keyword",
    ["switch"] = "keyword",
    ["case"] = "keyword",
    
    ["in"] = "keyword",
    ["lock"] = "keyword",
    ["unlock"] = "keyword",
    ["with"] = "keyword",
    ["using"] = "keyword",
    ["ref"] = "keyword",
    ["out"] = "keyword",
    ["requires"] = "keyword",
    ["ensures"] = "keyword",
    ["delegate"] = "keyword",
    
    ["throw"] = "keyword",
    ["throws"] = "keyword",
    ["try"] = "keyword",
    ["catch"] = "keyword",
    ["finally"] = "keyword",
    ["errordomain"] = "keyword",
    
    ["fundamental-struct-type"] = "keyword",
    ["user-defined-struct-type"] = "keyword",
    ["enumerated-type"] = "keyword",
    ["integral-type"] = "keyword",
    ["floating-point-type"] = "keyword",
    ["bool"] = "keyword",
    ["char"] = "keyword",
    ["uchar"] = "keyword",
    ["short"] = "keyword",
    ["ushort"] = "keyword",
    ["int"] = "keyword",
    ["uint"] = "keyword",
    ["long"] = "keyword",
    ["ulong"] = "keyword",
    ["size_t"] = "keyword",
    ["ssize_t"] = "keyword",
    ["int8"] = "keyword",
    ["uint8"] = "keyword",
    ["int16"] = "keyword",
    ["uint16"] = "keyword",
    ["int32"] = "keyword",
    ["uint32"] = "keyword",
    ["int64"] = "keyword",
    ["uint64"] = "keyword",
    ["unichar"] = "keyword",
    ["float"] = "keyword",
    ["double"] = "keyword",
    
    ["true"] = "literal",
    ["false"] = "literal",
    ["null"] = "literal"
  }
}
