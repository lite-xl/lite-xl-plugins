-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "CMake",
  files = { "%.cmake$", "CMakeLists.txt$" },
  comment = "#",
  block_comment = { "#[[", "]]" },
  patterns = {
    { pattern = { '#%[=*%[', '%]=*%]' }, type = "comment"  },
    { pattern = "#.*",                   type = "comment"  },
    { pattern = { '%[=*%[', '%]=*%]' },  type = "string"   },
    { pattern = { '"', '"', '\\' },      type = "string"   },
    { pattern = "[%a_][%w_]*%f[(]",      type = "function" },
    { pattern = "[%a_][%w_]*",           type = "normal"   },
    { pattern = "%${[%a_][%w_]*%}",      type = "operator" },
  },
  symbols = {},
}
