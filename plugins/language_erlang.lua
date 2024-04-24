-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Erlang",
  files = "%.erl$", "%.hrl$",
  comment = "%%",
  patterns = {
    { pattern = "%%.*",                                     type = "comment"  }, -- Single-line comment
    { regex   = "^\\w+(?!.+)",                              type = "literal"  }, -- Atom
    { regex   = "^\\'?\\w+\\s?\\w+\\'?(?!.+)",              type = "literal"  }, -- Atom with apices
    { pattern = { '"', '"', '\\' },                         type = "string"   }, -- String, quotes
    { pattern = { "'", "'", '\\' },                         type = "string"   }, -- String, apices
    { regex   = "\\w+[0-9]*(?=[)])",                        type = "symbol"   }, -- Field name
    { pattern = "-?0x%x+",                                  type = "number"   }, -- ?
    { pattern = "-?%d+[%deE]*f?",                           type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",                               type = "number"   }, -- ?
    { regex   = [[\-\>(?=\s)]],                             type = "function" }, -- Function arrow
    { pattern = "-?[%a_][%w_]*%f[(]",                       type = "function" }, -- Function name
    { regex   = "<<.+>>",                                   type = "keyword2" }, -- bit string
    { regex   = "\\#\\{.+\\}",                              type = "keyword2" }, -- map
    { pattern = "[%+%-=/%*%^<>!~|&]",                       type = "operator" }, -- Operators
    { regex   = "bnot|div|rem|band|bor|bxor|bsl|bsr",       type = "operator" }, -- Operators
  },
  symbols = {
    ["-export"]       = "keyword",
    ["-import"]       = "keyword",
    ["-module"]       = "keyword",
    ["-compile"]      = "keyword",
    
    ["after"]         = "keyword",
    ["and"]           = "keyword",
    ["andalso"]       = "keyword",
    ["band"]          = "keyword",
    ["begin"]         = "keyword",
    ["case"]          = "keyword",
    ["catch"]         = "keyword",
    ["cond"]          = "keyword",
    ["end"]           = "keyword",
    ["fun"]           = "keyword",
    ["if"]            = "keyword",
    ["let"]           = "keyword",
    ["not"]           = "keyword",
    ["of"]            = "keyword",
    ["or"]            = "keyword",
    ["oselse"]        = "keyword",
    ["receive"]       = "keyword",
    ["try"]           = "keyword",
    ["when"]          = "keyword",
    ["xor"]           = "keyword",
    
    ["true"]          = "literal",
    ["false"]         = "literal"
  }
}
