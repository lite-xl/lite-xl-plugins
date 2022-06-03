-- mod-version:3
local syntax = require "core.syntax"



syntax.add {
  name = "Gemtext",
  files = { "%.gmi$" },
  patterns = {
    { pattern = { "```", "```" },           type = "string"   },
    { pattern = "#.*",                      type = "keyword"  },
    { pattern = "%*%s",                     type = "keyword2" },
    { pattern = "=>",                       type = "function" },
    { pattern = "https?://%S+",             type = "literal"  },
    { pattern = "gemini?://%S+",            type = "literal"  },
    { pattern = ">.*",                      type = "comment"  },
    { pattern = ".*[>*#]",                  type = "normal"   },
    { pattern = ".*=>",                     type = "normal"   }
  },
  symbols = { },
}
