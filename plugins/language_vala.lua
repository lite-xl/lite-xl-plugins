-- mod-version:3
local syntax = require "core.syntax"

-- https://docs.vala.dev/tutorials/programming-language/main/02-00-basics/02-03-comments.html

syntax.add {
  name = "Vala",
  files = { "%.vala$" },
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    { pattern = "//.*",                                                  type = "comment"  }, -- Single-line comment
    { pattern = { "/%*", "%*/" },                                        type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                                      type = "string"   }, -- ?
    { pattern = { "'", "'", '\\' },                                      type = "string"   }, -- ?
    { pattern = "-?0x%x+",                                               type = "number"   }, -- ?
    { pattern = "-?%d+[%d%.eE]*f?",                                      type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",                                            type = "number"   }, -- ?
    { regex   = "\\w+(?=\\s+\\w++\\s+\\=\\s+)",                          type = "function" }, -- Class name in class instance
    { regex   = "\\<.+\\>",                                              type = "keyword2" }, -- Generic Type
    { pattern = "[%+%-=/%*%^%%<>!~|&]",                                  type = "operator" }, -- ?
    { pattern = "[%a_][%w_]*%f[(]",                                      type = "function" }, -- ?
    { regex   = [[\s?\:\s?(?:\w+\.?)+(?=\s?[{])]],                       type = "keyword2" }, -- Inheritance
    { regex   = [[\s?\:\s?(?:\w+(?:\<.+\>)?\s?\,?\s?)+(?=\s?[{])]],      type = "keyword2" }, -- Inheritance
    { regex   = [[class()\s+\w+()\<.+\>(?=\s?\:)]],                      type = { "keyword", "normal", "keyword2" } }, -- Generic Class Type
    { regex   = [[interface()\s+\w+()\<.+\>(?=\s?\:)]],                  type = { "keyword", "normal", "keyword2" } }, -- Generic Interface Type
    { regex   = "\\=\\>(?=[{])",                                         type = "keyword"  }, -- Lambda
    { regex   = "[A-Z][A-Z_]+",                                          type = "keyword2" }, -- Constants
    { regex   = "\\[.+\\](?=\\w*)",                                      type = "literal"  }, -- Attribute
    { regex   = "\\#\\w+(?=\\s?\\w*)",                                   type = "keyword"  }, -- Preprocessor directive
    { pattern = "[%a_][%w_]*",                                           type = "symbol"   }, -- ?
    -- FIX: @"$a * $b = $(a * b)" should be fully string-colored
    -- FIX: 21.to_string(); the . should be symbol-colored
    -- FIX: int[] a = new int[10] and int[] c = b[1:3];
    -- FIX: var l = new List<int>();  // same as: List<int> l = new List<int>();
    -- FIX: MyFoo<string, MyBar<string, int>> foo = new MyFoo<string, MyBar<string, int>>();
    -- FIX: : GLib.List<GLib.Value>
    -- FIX: <> and <<>> operators
    -- FIX: int method_name(int arg1, Object arg2) { Object is not colored properly
    -- 
  },
  symbols = {
    ["class"] = "keyword",
    ["this"] = "keyword",
    ["var"] = "keyword",
    ["const"] = "keyword",
    ["new"] = "keyword",
    ["enum"] = "keyword",
    ["namespace"] = "keyword",
    ["interface"] = "keyword",
    ["const"] = "keyword",
    ["construct"] = "keyword",
    ["virtual"] = "keyword",
    ["get"] = "keyword",
    ["set"] = "keyword",
    ["default"] = "keyword",
    ["signal"] = "keyword",
    ["struct"] = "keyword",
    ["Type"] = "keyword",
    ["string"] = "keyword",
    ["unowned"] = "keyword",
    
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
