-- mod-version:3
local syntax = require "core.syntax"

-- Language syntax reference
-- https://gnome.pages.gitlab.gnome.org/vala/manual/overview.html

syntax.add {
  name = "Vala",
  files = { "%.vala$" },
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    { pattern = "//.*",                                                                    type = "comment"  }, -- Single-line comment
    { pattern = { "/%*", "%*/" },                                                          type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                                                        type = "string"   }, -- String, double apices
    { pattern = { '@?"', '"', '\\' },                                                      type = "string"   }, -- Special string
    { pattern = { "'", "'", '\\' },                                                        type = "string"   }, -- String, apices
    { pattern = "-?0x%x+",                                                                 type = "number"   }, -- Numbers
    { pattern = "-?%d+[%d%.eE]*f?",                                                        type = "number"   }, -- Numbers
    { pattern = "-?%.?%d+f?",                                                              type = "number"   }, -- Numbers
    -- TODO: replace with multi-token lua patterns
    { regex   = "\\<(?:[\\w+][\\<\\w+\\>]\\,?\\s*)+\\>\\>*(?=[(]?[)]?[\\;\\s*])",          type = "keyword2" }, -- Generic Type
    -- TODO: replace with multi-token lua patterns
    { regex   = "(?>\\w+\\.?)+\\,?\\<.+?\\>\\>*(?=\\s+\\w+\\s*)?",                         type = "function" }, -- Generic class name reference
    -- TODO: replace with multi-token lua patterns
    { regex   = "(?>\\w+\\.?)+\\,?(?=\\s+\\w+\\s*)",                                       type = "function" }, -- Class name reference
    -- TODO: replace with multi-token lua patterns
    { regex   = "(?>\\w+\\.?)+(?=\\s+\\w+\\s*)?(?=\\s*\\{|\\:)",                           type = "function" }, -- Class name
    { pattern = "[%+%-=/%*%^%%<>!~|&]",                                                    type = "operator" }, -- Operators
    { pattern = "[%a_][%w_]*%f[(]",                                                        type = "function" }, -- Function
    { pattern = "%s*%:%s*",                                                                type = "keyword"  }, -- Inheritance
    -- TODO: replace with multi-token lua patterns ?
    { regex   = "\\=\\>(?=[{])",                                                           type = "keyword"  }, -- Lambda
    -- TODO: replace with lua patterns
    { regex   = "[A-Z](?:[A-Z_][\\d]*)+(?!\\w)",                                           type = "keyword2" }, -- Constants
    { pattern = "^%s*%[.*%]",                                                              type = "literal"  }, -- Attribute
    -- TODO: replace with multi-token lua patterns ?
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
