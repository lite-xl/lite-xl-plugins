-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"



syntax.add {
  files = { "%.gmi$" },
  patterns = {
    { pattern = { "```", "```" },           type = "string"   },
    { pattern = "#.-\n",                    type = "keyword"  },
    { pattern = "%*.*\n",                   type = "keyword2" },
    { pattern = "=>",                       type = "function" },    
    { pattern = "!?%[.-%]%(.-%)",           type = "function" },
    { pattern = "https?://%S+",             type = "literal"  },
    { pattern = "gemini?://%S+",            type = "literal"  },
    { pattern = ">.*",                      type = "comment"  },
    { pattern = ".*[>*#]",                  type = "normal"   },
    { pattern = ".*=>",                     type = "normal"   }
  },
  symbols = { },
}
