-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "LilyPond",
  files = { "%.i?ly$" },
  comment = "%%",
  block_comment = { "%%{", "%%}" },
  patterns = {
    { pattern = "#%(()[%a_]%S*",          type = { "operator", "function" } },
    { pattern = {"%%{", "%%}"},           type = "comment"  },
    { pattern = "%%.*",                   type = "comment"  },
    { pattern = "#[%w_-]*",               type = "keyword2" },
    { pattern = "\\%a%w+",                type = "keyword"  },
    { pattern = "\\\\",                   type = "operator" },
    { pattern = "[%(%){}%[%]<>=/~%-%_']", type = "operator" },
    { pattern = {'"', '"', "\\"},         type = "string"   },
    { pattern = "-?%.?%d+",               type = "number"   },
  },
  symbols = {}
}

