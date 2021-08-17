-- mod-version:2 -- lite-xl 2.0
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
