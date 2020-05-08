local syntax = require "core.syntax"

syntax.add {
  files = { "%.sh$" },
  comment = "#",
  patterns = {
    { pattern = "#.*\n",                  type = "comment"  },
    { pattern = [[\.]],                   type = "normal"   },
    { pattern = { '"', '"', '\\' },       type = "string"   },
    { pattern = { "'", "'", '\\' },       type = "string"   },
    { pattern = { '`', '`', '\\' },       type = "string"   },
    { pattern = "%f[%w_][%d%.]+%f[^%w_]", type = "number"   },
    { pattern = "[!<>|%[%]=*]",           type = "operator" },
    { pattern = "%f[%S]%-[%w%-_]+",       type = "function" },
    { pattern = "${.*}",                  type = "keyword2" },
    { pattern = "$[%a_@*][%w_]*",         type = "keyword2" },
    { pattern = "[%a_][%w_]*",            type = "symbol"   },
  },
  symbols = {
    ["if"]    = "keyword",
    ["then"]  = "keyword",
    ["elif"]  = "keyword",
    ["else"]  = "keyword",
    ["fi"]    = "keyword",
    ["for"]   = "keyword",
    ["while"] = "keyword",
    ["until"] = "keyword",
    ["in"]    = "keyword",
    ["do"]    = "keyword",
    ["done"]  = "keyword",
    ["echo"]  = "keyword",
    ["true"]  = "literal",
    ["false"] = "literal",
  },
}

