-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

syntax.add {
  files = { "%.bib$" },
  comment = "%%",
  patterns = {
    { pattern = {"%%", "\n"},     type = "comment"   },
    { pattern = "@%a+",           type = "keyword"   },
    { pattern = "%a+%s=",         type = "keyword2"  },
  },
  symbols = {
    ["author"] = "keyword",
    ["doi"] = "keyword",
    ["issue"] = "keyword",
    ["journal"] = "keyword",
    ["month"] = "keyword",
    ["numpages"] = "keyword",
    ["pages"] = "keyword",
    ["publisher"] = "keyword",
  }
}
