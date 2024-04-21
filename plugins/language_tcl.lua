-- mod-version:4
local syntax = require "core.syntax"

syntax.add {
  name = "Tcl",
  files = { "%.tcl$" },
  comment = "#",
  patterns = {
    { pattern = "#.-\n",                 type = "comment" },
    { pattern = { '"', '"', '\\' },      type = "string"  },
    { pattern = "0x%x+",                 type = "number"  },
    { pattern = "%d+[%d%.eE]*f?",        type = "number"  },
    { pattern = "%.?%d+f?",              type = "number"  },
    { pattern = "%$[%a_][%w_]*",         type = "literal" },
    { pattern = "[%+%-=/%*%^%%<>!~|&]",  type = "operator" },
    { pattern = "::[%a_][%w_]*",         type = "function" },
    { pattern = "[%a_][%w_]*%f[:]",      type = "function" },
    { pattern = "[%a_][%w_]*",           type = "symbol" },
  },
  symbols = {
    ["set"]       = "keyword",
    ["unset"]       = "keyword",
    ["rename"]       = "keyword",
    ["upvar"]     = "keyword",
    ["incr"]      = "keyword",
    ["source"]     = "keyword",
    ["expr"]     = "keyword",
    ["gets"]     = "keyword",
    ["puts"]     = "keyword",
    ["package"]   = "keyword",
    ["list"]   = "keyword",
    ["dict"]   = "keyword",
    ["split"]    = "join",
    ["concat"]    = "join",
    ["lappend"]   = "keyword",
    ["lset"]   = "keyword",
    ["lassign"]   = "keyword",
    ["lindex"]   = "keyword",
    ["llength"]  = "keyword",
    ["lsearch"]   = "keyword",
    ["lrange"]   = "keyword",
    ["linsert"] = "keyword",
    ["lreplace"] = "keyword",
    ["lrepeat"] = "keyword",
    ["lsort"]   = "keyword",
    ["lreverse"]   = "keyword",
    ["array"]   = "keyword",
    ["concat"]   = "keyword",
    ["regexp"]   = "keyword",
    ["for"]       = "keyword",
    ["foreach"]       = "keyword",
    ["while"]     = "keyword",
    ["case"]     = "keyword",
    ["proc"]     = "keyword",
    ["if"]    = "keyword",
    ["else"]      = "keyword",
    ["elseif"]      = "keyword",
    ["break"]    = "keyword",
    ["continue"] = "keyword",
    ["return"]   = "keyword",
    ["eval"]   = "keyword",
    ["try"]      = "keyword2",
    ["on"]      = "keyword2",
    ["finally"]      = "keyword2",
    ["throw"]    = "keyword2",
    ["error"]    = "keyword2",
  },
}

