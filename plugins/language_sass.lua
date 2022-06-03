-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Sass",
  files = { "%.sass$" ,"%.scss$"},
  comment = "//",
  patterns = {
    { pattern = "/[/%*].-\n",             type = "comment"  },
    { pattern = { '"', '"', '\\' },       type = "string"   },
    { pattern = { "'", "'", '\\' },       type = "string"   },
    { pattern = "$%w+",                   type = "keyword"  },
    { pattern = "@%w+",                   type = "literal"  },
    { pattern = "[#,]%w+",                type = "function" },
    { pattern = "&",                      type = "keyword2" },
    { pattern = "[:%/%*%-]",              type = "operator" },
    { pattern = "[%a][%w-]*%s*%f[:]",     type = "keyword2" },
    { pattern = "-?%d+[%d%.]*p[xt]",      type = "number"   },
    { pattern = "-?%d+[%d%.]*deg",        type = "number"   },
    { pattern = "-?%d+[%d%.]*[s%%]",      type = "number"   },
    { pattern = "-?%d+[%d%.]*",           type = "number"   },
    { pattern = "[%a_][%w_]*",            type = "symbol"   },
  },
  symbols = {
    ["transparent"] = "literal",
    ["none"]        = "literal",
    ["absolute"]    = "literal",
    ["relative"]    = "literal",
    ["solid"]       = "literal",
    ["flex"]        = "literal",
    ["flex-start"]  = "literal",
    ["flex-end"]    = "literal",
    ["row"]         = "literal",
    ["center"]      = "literal",
    ["column"]      = "literal",
    ["pointer"]     = "literal",
    ["ease"]        = "literal",
    ["white"]      = "function",
    ["black"]      = "function",
    ["gray"]       = "function",
    ["blue"]       = "function",
    ["red"]        = "function",
    ["purple"]     = "function",
    ["green"]      = "function",
    ["yellow"]     = "function"
  }
}
