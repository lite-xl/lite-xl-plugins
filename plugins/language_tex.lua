-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "TeX",
  files = { "%.tex$", "%.dtx$", "%.sty$", "%.ins$", "%.cls$" },
  comment = "%%",
  patterns = {
    { pattern = "%%.-\n",                  type = "comment"  },
    { pattern = "\\documentclass().-{()%a%w+()}",  type = {"keyword", "symbol", "function", "symbol"} },
    { pattern = "\\usepackage",            type = "keyword"  },
    { pattern = "\\chapter",               type = "keyword"  },
    { pattern = "\\section",               type = "keyword"  },
    { pattern = "\\subsection",            type = "keyword"  },
    { pattern = "\\paragraph",             type = "keyword"  },
    { pattern = "\\subparagraph",          type = "keyword"  },
    { pattern = "\\begin(){()%a%w+()}",    type = {"keyword2", "symbol", "function", "symbol"} },
    { pattern = "\\end(){()%a%w+()}",      type = {"keyword2", "symbol", "function", "symbol"} },
    { pattern = "\\%a%w+()%*",             type = {"keyword2", "operator"} },
    { pattern = "\\%a%w+",                 type = "keyword2"  },
    { pattern = "&",                       type = "operator"  },
    { pattern = "\\\\",                    type = "operator"  },
    { pattern = "%$",                      type = "operator"   },
    { pattern = "\\[%[%]()]",              type = "operator"   },
  },
  symbols = {}
}
