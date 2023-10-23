-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "MARTe",
  files = { "%.mrt$", "%.marte$" },
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    { pattern = "//.*",                        type = "comment"  },
    { pattern = { "/%*", "%*/" },           type = "comment"  },
    { pattern = { '"', '"', '\\' },            type = "string"   },
    { pattern = { "'", "'", '\\' },            type = "string"   },
    { pattern = "%-?%.inf",                    type = "number"   },
    { pattern = "%.NaN",                       type = "number"   },
    {
      pattern = "Class%s+()=()%s+[%a_][%w_:]*",
      type = { "keyword", "operator", "keyword2"}
    },
    {
      pattern = "Type%s+()=()%s+[%a_][%w_]*",
      type = { "keyword", "operator", "keyword2"}
    },
    {
      pattern = "[%+%$][%a_][%w_]+%s()=",
      type = {"function", "operator"}
    },
    { pattern = "=%s+()[%a_][%w_]+", type = "string" },
    {
      pattern = "[%a_][%w_]+%s()=",
      type = {"keyword", "operator"}
    },
    { pattern = "0x%x+",                    type = "number"   },
    { pattern = "%d+[%d%.'eE]*f?",          type = "number"   },
    { pattern = "%.?%d+f?",                 type = "number"   },
    { pattern = "%a[%w_]+",                 type = "literal"  },
  },
  symbols = {
    ["true"]  = "number",
    ["false"] = "number",
  },
}
