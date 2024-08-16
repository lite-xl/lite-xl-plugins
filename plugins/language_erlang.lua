-- mod-version:3
local syntax = require "core.syntax"

-- https://www.erlang.org/doc/system/reference_manual.html

-- WIP: https://www.erlang.org/doc/system/ref_man_records.html#updating-records

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
    -- FIX: fix number coloring in field names
    -- FIX: add missing number formats
    -- FIX: true or false, true is colored like an atom
    -- FIX: try should be colored as keyword
    -- TODO: add support for records
    -- TODO: add support for nested records
    -- TODO: color rec#{...}, set#{...} and similar
    -- TODO: add support for macros
    -- FIX: number strings inside multi-line """ ... """
    -- FIX: ~S/Example "docs"/ and ~B|Example "docs"| should be colored as string
    -- FIX: end.
    -- 
  },
  symbols = {
    ["after"]         = "keyword",
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
    ["maybe"]         = "keyword",

    ["onhook"]        = "keyword",
    ["connect"]       = "keyword",
    ["timeout"]       = "keyword",

    ["and"]           = "keyword",
    ["andalso"]       = "keyword",
    ["xor"]           = "keyword",
    ["bnot"]          = "keyword",
    ["div"]           = "keyword",
    ["rem"]           = "keyword",
    ["band"]          = "keyword",
    ["bor"]           = "keyword",
    ["bxor"]          = "keyword",
    ["bsl"]           = "keyword",
    ["bsr"]           = "keyword",
    
    ["true"]          = "literal",
    ["false"]         = "literal",
  }
}
