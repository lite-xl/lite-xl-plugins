-- mod-version:1 -- lite-xl 2.00
local syntax = require "core.syntax"

syntax.add {
  files = { "%.po$", "%.pot$" },
  comment = "#",
  patterns = {
    { pattern = { "#", "\n"},        type = "comment"  },
    { pattern = { '"', '"', '\\' },  type = "string"   },
    { pattern = "[%[%]]",            type = "operator" },
    { pattern = "%d+",               type = "number"   },
    { pattern = "[%a_][%w_]*",       type = "symbol"   },
  },
  symbols = {
    ["msgctxt"]      = "keyword",
    ["msgid"]        = "keyword",
    ["msgid_plural"] = "keyword",
    ["msgstr"]       = "keyword",
  },
}
