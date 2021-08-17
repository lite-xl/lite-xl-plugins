-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

syntax.add {
  files = { "%.cmake$", "CMakeLists.txt$" },
  comment = "//",
  patterns = {
    { pattern = { "#", "[^\\]\n" },     type = "comment"  },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
    { pattern = "[%a_][%w_]*",          type = "normal"   },
	{ pattern = "%${[%a_][%w_]*%}",     type = "operator"   },
  },
  symbols = {},
}
