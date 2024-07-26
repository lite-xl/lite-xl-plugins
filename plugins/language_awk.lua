-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Awk script",
  files = "%.awk$",
  headers = "^#!.*bin.*awk",
  comment = "#",
  patterns = {
    -- $# is a awk special variable and the '#' shouldn't be interpreted
    -- as a comment.
    { pattern = "%$[%a_@*#][%w_]*",               type = "keyword2" },
    -- Comments
    { pattern = "#.*",                            type = "comment"  },
    -- Strings
    { pattern = { '"', '"', '\\' },               type = "string"   },
    { pattern = { "'", "'", '\\' },               type = "string"   },
    { pattern = { '`', '`', '\\' },               type = "string"   },
    -- Ignore numbers that start with dots or slashes
    { pattern = "%f[%w_%.%/]%d[%d%.]*%f[^%w_%.]", type = "number"   },
    -- Operators
    { pattern = "[!<>|&%[%]:=*]",                 type = "operator" },
    -- Match parameters
    { pattern = "%f[%S][%+%-][%w%-_:]+",          type = "function" },
    { pattern = "%f[%S][%+%-][%w%-_]+%f[=]",      type = "function" },
    -- Prevent parameters with assignments from been matched as variables
    {
      pattern = "%s%-%a[%w_%-]*()%s+()%d[%d%.]+",
      type = { "function", "normal", "number" }
    },
    {
      pattern = "%s%-%a[%w_%-]*()%s+()%a[%a%-_:=]+",
      type = { "function", "normal", "symbol" }
    },
    -- Match variable assignments
    { pattern = "[_%a][%w_]+%f[%+=]",              type = "keyword2" },
    -- Match variable expansions
    { pattern = "%${.-}",                          type = "keyword2" },
    { pattern = "%$[%d%$%a_@*][%w_]*",             type = "keyword2" },
    -- Functions
    { pattern = "[%a_%-][%w_%-]*()%s*%f[(]",       type = { "function", "normal" } },
    -- Everything else
    { pattern = "[%a_][%w_]*",                     type = "symbol"   },
  },
  symbols = {
    ["break"]       = "keyword",
    ["continue"]    = "keyword",
    ["do"]          = "keyword",
    ["delete"]      = "keyword",
    ["else"]        = "keyword",
    ["exit"]        = "keyword",
    ["for"]         = "keyword",
    ["function"]    = "keyword",
    ["getline"]     = "keyword",
    ["if"]          = "keyword",
    ["next"]        = "keyword",
    ["nextfile"]    = "keyword",
    ["print"]       = "keyword",
    ["printf"]      = "keyword",
    ["return"]      = "keyword",
    ["while"]       = "keyword",
    ["gsub"]        = "keyword",
    ["index"]       = "keyword",
    ["length"]      = "keyword",
    ["match"]       = "keyword",
    ["split"]       = "keyword",
    ["sprintf"]     = "keyword",
    ["sub"]         = "keyword",
    ["substr"]      = "keyword",
    ["tolower"]     = "keyword",
    ["toupper"]     = "keyword",
    ["atan2"]       = "keyword",
    ["cos"]         = "keyword",
    ["exp"]         = "keyword",
    ["int"]         = "keyword",
    ["log"]         = "keyword",
    ["rand"]        = "keyword",
    ["sin"]         = "keyword",
    ["sqrt"]        = "keyword",
    ["srand"]       = "keyword",
    ["BEGIN"]       = "keyword",
    ["END"]         = "keyword",
    ["ARGC"]        = "keyword",
    ["ARGV"]        = "keyword",
    ["FILENAME"]    = "keyword",
    ["FNR"]         = "keyword",
    ["FS"]          = "keyword",
    ["NF"]          = "keyword",
    ["NR"]          = "keyword",
    ["OFMT"]        = "keyword",
    ["OFS"]         = "keyword",
    ["ORS"]         = "keyword",
    ["RLENGTH"]     = "keyword",
    ["RS"]          = "keyword",
    ["RSTART"]      = "keyword",
    ["SUBSEP"]      = "keyword",
    ["ARGIND"]      = "keyword",
    ["BINMODE"]     = "keyword",
    ["CONVFMT"]     = "keyword",
    ["ENVIRON"]     = "keyword",
    ["ERRNO"]       = "keyword",
    ["FIELDWIDTHS"] = "keyword",
    ["IGNORECASE"]  = "keyword",
    ["LINT"]        = "keyword",
    ["PROCINFO"]    = "keyword",
    ["RT"]          = "keyword",
    ["RLENGTH"]     = "keyword",
    ["TEXTDOMAIN"]  = "keyword"
  }
}
