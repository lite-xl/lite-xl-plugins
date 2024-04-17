-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "OCaml",
  files = { "%.ml$" },
  comment = "",
  patterns = {
    { pattern = "%-%-.*",               type = "comment"  }, -- ?
    { pattern = { "{%-", "%-}" },       type = "comment"  }, -- ?
    { pattern = { '"', '"', '\\' },     type = "string"   }, -- ?
    { pattern = { "'", "'", '\\' },     type = "string"   }, -- ?
    { pattern = "-?0x%x+",              type = "number"   }, -- ?
    { pattern = "-?%d+[%d%.eE]*f?",     type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",           type = "number"   }, -- ?
  },
  symbols = {
    [""] = "keyword",
  },
}
