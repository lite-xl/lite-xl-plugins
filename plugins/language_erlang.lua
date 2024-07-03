-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Erlang",
  files = "%.erl$", "%.hrl$",
  comment = "%%",
  patterns = {
    { pattern = "%%.*",                                             type = "comment"  }, -- Single-line comment
    { regex   = "^\\w+(?!.+)",                                      type = "literal"  }, -- Atom
    { regex   = "^\\'?\\w+\\s?\\w+\\'?(?!.+)",                      type = "literal"  }, -- Atom with apices
    { pattern = { '"', '"', '\\' },                                 type = "string"   }, -- String, quotes
    { pattern = { "'", "'", '\\' },                                 type = "string"   }, -- String, apices
    { regex   = "\\w+[0-9]*(?=[)])",                                type = "symbol"   }, -- Field name
    { pattern = "-?0x%x+",                                          type = "number"   }, -- ?
    { pattern = "-?%d+[%deE]*f?",                                   type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",                                       type = "number"   }, -- ?
    { regex   = "\\$\\w+(?=\\s?\\=?)",                              type = "keyword2" }, -- Type
    { regex   = "[a-zA-Z0-9_]+\\#[a-zA-Z0-9_]+",                    type = "keyword2" }, -- Type
    { regex   = "^\\-\\w+",                                         type = "keyword"  }, -- Modules
    { regex   = [[\-\>(?=\s)]],                                     type = "function" }, -- Function arrow
    { pattern = "-?[%a_][%w_]*%f[(]",                               type = "function" }, -- Function name
    { regex   = "^\\w+(?!.+)",                                      type = "keyword2" }, -- Atom
    { regex   = "^\\'?\\w+\\s?\\w+\\'?(?!.+)",                      type = "keyword2" }, -- Atom
    { regex   = "<<.+>>",                                           type = "keyword2" }, -- Bit string
    { pattern = "[%+%-=/%*%^<>!~|&?]",                              type = "operator" }, -- Operators
    { regex   = "bnot|div|rem|band|bor|bxor|bsl|bsr",               type = "operator" }, -- Operators
    -- TODO: add missing number expressions
    -- FIXME: fix number coloring in field names
    -- FIXME: add missing number formats
    -- FIXME: true or false, true is colored like an atom
    -- FIXME: try should be colored as keyword
    -- TODO: add support for records
    -- TODO: color rec#{...}, set#{...} and similar
    -- TODO: add support for nested records
    -- TODO: add support for macros
  },
  symbols = {
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
    ["orelse"]        = "keyword",
    ["receive"]       = "keyword",
    ["try"]           = "keyword",
    ["when"]          = "keyword",
    ["xor"]           = "keyword",
    ["maybe"]         = "keyword",
    
    ["true"]          = "literal",
    ["false"]         = "literal",
  }
}
