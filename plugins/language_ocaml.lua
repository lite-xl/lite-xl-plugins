-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax references
-- https://ocaml.org/manual/5.2/lex.html#

-- Real world examples
-- https://github.com/ocaml-community/awesome-ocaml
-- https://github.com/ocaml-batteries-team/batteries-included
-- 

-- WIP: https://ocaml.org/manual/5.2/expr.html

syntax.add {
  name = "OCaml",
  files = { "%.mli?$" },
  block_comment = { "(*", "*)" },
  patterns = {
    { pattern = { "%(%*", "%*%)", '\\' },           type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                 type = "string"   }, -- String
    { regex   = "\\'\\w+(?=\\s|[)]|\\:)",           type = "keyword2" }, -- Special variable ('a)
    { regex   = "\\w+\\'(?=\\s|[)]|\\:)",           type = "keyword2" }, -- Special variable (h')
    { pattern = { "'", "'", '\\' },                 type = "literal"  }, -- Character literal
    { regex   = "-?(?:\\d_?)+(?:.\\d+)?",           type = "number"   }, -- Numbers
    { regex   = "-?0x[0-9a-fA-F]+",                 type = "number"   }, -- Exadecimal Numbers
    { regex   = "\\<\\w*\\>",                       type = "literal"  }, -- Function ?
    { regex   = "\\:\\s*\\w+",                      type = "keyword2" }, -- Field type
    { pattern = "[%+%-=/%*%^%%<>!~|&_:]",           type = "operator" }, -- Operators
    { regex   = "\\#\\#",                           type = "keyword"  }, -- ##
    { regex   = [[\-\>(?=\s)]],                     type = "function" }, -- Function arrow
    { pattern = "-?[%a_][%w_]*%f[(]",               type = "function" }, -- Function name
    { pattern = "[%a_][%w_]*",                      type = "symbol"   }, -- ?
    -- FIX: nested comments
    -- FIX: match n spaces between function-name and ()
    -- FIX: add char pattern
    -- FIX: add pattern for quoted string
    -- FIX: :: should be colored as operator
  },
  symbols = {
    ["and"] = "keyword",
    ["as"] = "keyword",
    ["asr"] = "keyword",
    ["assert"] = "keyword",
    ["begin"] = "keyword",
    ["class"] = "keyword",
    ["constraint"] = "keyword",
    ["do"] = "keyword",
    ["done"] = "keyword",
    ["downto"] = "keyword",
    ["else"] = "keyword",
    ["end"] = "keyword",
    ["exception"] = "keyword",
    ["external"] = "keyword",
    ["for"] = "keyword",
    ["fun"] = "keyword",
    ["function"] = "keyword",
    ["functor"] = "keyword",
    ["if"] = "keyword",
    ["in"] = "keyword",
    ["include"] = "keyword",
    ["inherit"] = "keyword",
    ["initializer"] = "keyword",
    ["land"] = "keyword",
    ["lazy"] = "keyword",
    ["let"] = "keyword",
    ["lor"] = "keyword",
    ["lsl"] = "keyword",
    ["lsr"] = "keyword",
    ["lxor"] = "keyword",
    ["match"] = "keyword",
    ["method"] = "keyword",
    ["mod"] = "keyword",
    ["module"] = "keyword",
    ["open"] = "keyword",
    ["mutable"] = "keyword",
    ["new"] = "keyword",
    ["nonrec"] = "keyword",
    ["object"] = "keyword",
    ["of"] = "keyword",
    ["open!"] = "keyword",
    ["or"] = "keyword",
    ["private"] = "keyword",
    ["rec"] = "keyword",
    ["sig"] = "keyword",
    ["struct"] = "keyword",
    ["then"] = "keyword",
    ["to"] = "keyword",
    ["try"] = "keyword",
    ["type"] = "keyword",
    ["val"] = "keyword",
    ["virtual"] = "keyword",
    ["when"] = "keyword",
    ["while"] = "keyword",
    ["with"] = "keyword",

    ["true"] = "literal",
    ["false"] = "literal",
  },
}
