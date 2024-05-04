-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "OCaml",
  files = { "%.ml$" },
  block_comment = { "(*", "*)" },
  patterns = {
    { pattern = { "%(%*", "%*%)", '\\' },     type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },           type = "string"   }, -- String
    { pattern = "-?0x%x+%-?%_?%x+",           type = "number"   }, -- Number to fix
    { pattern = "-?%d+[%d%.eE]*f?",           type = "number"   }, -- Number
    { pattern = "-?%.?%d+f?",                 type = "number"   }, -- Number
    { regex   = "\\<\\w*\\>",                 type = "literal"  }, -- Function ?
    { regex   = "\\:\\s?\\w+",                type = "keyword2" }, -- Field type
    { pattern = "[%+%-=/%*%^%%<>!~|&_:]",     type = "operator" }, -- Operators
    { regex   = [[\-\>(?=\s)]],               type = "function" }, -- Function arrow
    { pattern = "-?[%a_][%w_]*%f[(]",         type = "function" }, -- Function name
    { pattern = "[%a_][%w_]*",                type = "symbol"   }, -- ?
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
    ["false"] = "keyword",
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
    ["open"] = "keyword",
    ["open!"] = "keyword",
    ["or"] = "keyword",
    ["private"] = "keyword",
    ["rec"] = "keyword",
    ["sig"] = "keyword",
    ["struct"] = "keyword",
    ["then"] = "keyword",
    ["to"] = "keyword",
    ["true"] = "keyword",
    ["try"] = "keyword",
    ["type"] = "keyword",
    ["val"] = "keyword",
    ["virtual"] = "keyword",
    ["when"] = "keyword",
    ["while"] = "keyword",
    ["with"] = "keyword",
  },
}
