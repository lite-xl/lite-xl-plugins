-- mod-version:1 -- lite-xl 2.00
local syntax = require "core.syntax"

syntax.add {
  files = { "Makefile", "makefile", "%.mk$" },
  comment = "#",
  patterns = {
    { pattern = "#.*\n",                  type = "comment"  },
    { pattern = [[\.]],                   type = "normal"   },
    { pattern = "$[@^<%%?+|*]",           type = "keyword2" },
    { pattern = "$%(.-%)",                type = "variable" },
    { pattern = "%f[%w_][%d%.]+%f[^%w_]", type = "number"   },
    { pattern = "%..*:",                  type = "keyword2" },
    { pattern = ".*:",                    type = "function" },
  },
  symbols = {
  },
}
