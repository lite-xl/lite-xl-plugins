-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "LilyPond",
  files = { "%.ly$" },
  comment = "%%",
  patterns = {
    { pattern = "#%(()[%a_]%S*",          type = { "operator", "function" } },
    { pattern = "%%.-\n",                 type = "comment"  },
    { pattern = "#[%w_-]*",               type = "keyword2" },
    { pattern = "\\%a%w+",                type = "keyword"  },
    { pattern = "\\\\",                   type = "operator" },
    { pattern = "[%(%){}%[%]<>=/~%-%_']", type = "operator" },
    { pattern = {'"', '"', "\\"},         type = "string"   },
    { pattern = "-?%.?%d+",               type = "number"   },
  },
  symbols = {}
}
