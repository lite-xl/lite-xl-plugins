-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "BibTeX",
  files = { "%.bib$" },
  comment = "%%",
  patterns = {
    { pattern = "%%.*",           type = "comment"   },
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
