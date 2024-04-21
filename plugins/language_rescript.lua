-- mod-version:4
local syntax = require "core.syntax"

syntax.add {
  name = "ReScript",
  files = { "%.res$" },
  comment = "//",
  patterns = {
    { pattern = "//.-\n",               type = "comment"  },
    { pattern = { "/%*", "%*/" },       type = "comment"  },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = { "`", "`", '\\' },     type = "string"   },
    { pattern = "#[%a_][%w_]*",         type = "literal"   },
    { pattern = "0x[%da-fA-F]+",        type = "number"   },
    { pattern = "-?%d+[%d%.eE]*",       type = "number"   },
    { pattern = "-?%.?%d+",             type = "number"   },
    { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" },
    { pattern = "%f[^%.>]%l[%w_]*",     type = "function" },
    { pattern = "%l[%w_]*%f[(]",        type = "function" },
    { pattern = "%u[%w_]*",             type = "keyword2" },
    { pattern = "[%l_][%w_%.]*",        type = "symbol"   },
    { pattern = "@%l[%w_]*",            type = "string"   },
  },
  symbols = {
    ["and"] = "keyword",
    ["array"] = "keyword2",
    ["as"] = "keyword",
    ["assert"] = "keyword",
    ["bool"] = "keyword2",
    ["constraint"] = "keyword",
    ["downto"] = "keyword",
    ["else"] = "keyword",
    ["exception"] = "keyword",
    ["external"] = "keyword",
    ["false"] = "literal",
    ["for"] = "keyword",
    ["if"] = "keyword",
    ["in"] = "keyword",
    ["int"] = "keyword2",
    ["include"] = "keyword",
    ["lazy"] = "keyword",
    ["let"] = "keyword",
    ["module"] = "keyword",
    ["mutable"] = "keyword",
    ["of"] = "keyword",
    ["open"] = "keyword",
    ["option"] = "keyword2",
    ["rec"] = "keyword",
    ["switch"] = "keyword",
    ["string"] = "keyword2",
    ["to"] = "keyword",
    ["true"] = "literal",
    ["try"] = "keyword",
    ["type"] = "keyword",
    ["when"] = "keyword",
    ["while"] = "keyword",
    ["with"] = "keyword",
  }
}
