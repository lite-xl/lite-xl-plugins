-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Erlang",
  files = "%.erl$", "%.hrl$",
  comment = "%%",
  patterns = {
    { pattern = "%%.*",                                type = "comment"  }, -- Single-line comment
    { pattern = { '"', '"', '\\' },                    type = "string"   }, -- String, quotes
    { pattern = { "'", "'", '\\' },                    type = "string"   }, -- String, apices
    { regex   = "\\w+[0-9]*(?=[)])",                   type = "symbol"   }, -- Field name
    { pattern = "-?0x%x+",                             type = "number"   }, -- ?
    { pattern = "-?%d+[%deE]*f?",                      type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",                          type = "number"   }, -- ?
    { regex   = "[a-zA-Z0-9]_[a-zA-Z0-9]+(?=//s//s)",  type = "keyword2" }, -- Atom
    { regex   = [[\-\>(?=\s)]],                        type = "function" }, -- Function arrow
    { pattern = "-?[%a_][%w_]*%f[(]",                  type = "function" }, -- Function name
    { regex   = "<<.+>>",                              type = "keyword2" }, -- bit string
    { regex   = "\\#\\{.+\\}",                         type = "keyword2" }, -- map
    { pattern = "[%+%-=/%*%^<>!~|&]",                  type = "operator" }, -- Operators
    { regex   = "(?<=\\s?\\d)\\%(?=\\s?\\d)",          type = "operator" }, -- % operator
    { regex   = "(?<=\\s?\\d)rem(?=\\s?\\d)",          type = "operator" }, -- rem operator
    { regex   = "(?<=\\s?\\d)div(?=\\s?\\d)",          type = "operator" }, -- div operator
    -- TODO: map
  },
  symbols = {
    ["-export"]       = "keyword",
    ["-module"]       = "keyword",
    ["after"]         = "keyword",
    ["and"]           = "keyword",
    ["andalso"]       = "keyword",
    ["band"]          = "keyword",
    ["begin"]         = "keyword",
    ["bnot"]          = "keyword",
    ["bor"]           = "keyword",
    ["bsl"]           = "keyword",
    ["bsr"]           = "keyword",
    ["bxor"]          = "keyword",
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
