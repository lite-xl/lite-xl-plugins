-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax References
-- https://www.erlang.org/doc/system/reference_manual.html
-- https://erlang.org/documentation/doc-5.6/pdf/reference_manual.pdf

syntax.add {
  name = "Erlang",
  files = "%.erl$", "%.hrl$",
  comment = "%%",
  patterns = {
    { pattern = "%%.*",                                             type = "comment"  }, -- Single-line comment
    { regex   = "^\\w+(?!.+)",                                      type = "literal"  }, -- Atom
    { regex   = "^\\'?\\w+\\s?\\w+\\'?(?!.+)",                      type = "literal"  }, -- Atom with apices
    { regex   = "^\\w+\\@\\w+",                                     type = "literal"  }, -- Atom with @
    { pattern = { '"', '"', '\\' },                                 type = "string"   }, -- String, quotes
    { pattern = { "'", "'", '\\' },                                 type = "string"   }, -- String, apices
    { regex   = "\\w+[0-9]*(?=[)])",                                type = "symbol"   }, -- Field name
    { regex   = "^\\$\\\\n",                                        type = "number"   }, -- Numbers, $\n
    { regex   = "^\\$(?:\\w|\\n)",                                  type = "number"   }, -- Numbers, $char
    { regex   = "(?:\\d_?)+\\#(?:\\w)+",                            type = "number"   }, -- Numbers, base#value
    { regex   = "[+|-]?(?:\\d_?)+[eE]?(?:.\\d+[eE]?_?\\d*)?",       type = "number"   }, -- Numbers
    { regex   = "\\$\\w+(?=\\s?\\=?)()\n",                          type = { "keyword2", "literal" } }, -- Type
    { regex   = "[a-zA-Z0-9_]+()\\#[a-zA-Z0-9_]+",                  type = { "function", "keyword2" } }, -- Updating records
    { regex   = "\\#\\w*",                                          type = "keyword2" }, -- Records
    { regex   = "^\\-\\w+",                                         type = "keyword"  }, -- Modules
    { regex   = [[\-\>(?=\s)]],                                     type = "function" }, -- Function arrow
    { pattern = "-?[%a_][%w_]*%f[(]",                               type = "function" }, -- Function name
    { regex   = "^\\w+(?!.+)",                                      type = "keyword2" }, -- Atom
    { regex   = "^\\'?\\w+\\s?\\w+\\'?(?!.+)",                      type = "keyword2" }, -- Atom
    { regex   = "<<.+>>",                                           type = "keyword2" }, -- Bit string
    { pattern = "[%+%-=/%*%^<>!~|&?]",                              type = "operator" }, -- Operators
    { regex   = "^\\-doc()\\s\\~.+",                                type = { "keyword", "string" } }, -- Docs
    { pattern = "[%a_][%w_]*",                                      type = "symbol"   }, -- Symbols
    -- FIX: fix number coloring in field names
    -- FIX: ~S/Example "docs"/ and ~B|Example "docs"| should be colored as strings
    -- FIX: number strings inside multi-line """ ... """ (requires subsyntax)
    -- TODO: add support for macros
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
