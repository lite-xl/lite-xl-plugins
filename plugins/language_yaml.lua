-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

syntax.add {
  files = { "%.yml$", "%.yaml$" },
  comment = "#",
  patterns = {
    { pattern = { "#", "\n"},                  type = "comment"  },
    { pattern = { '"', '"', '\\' },            type = "string"   },
    { pattern = { "'", "'", '\\' },            type = "string"   },
    { pattern = "%-?%.inf",                    type = "number"   },
    { pattern = "%.NaN",                       type = "number"   },
    {
      pattern = "%&()%g+",
      type = { "keyword", "literal" }
    },
    { pattern = "!%g+",                        type = "keyword"  },
    { pattern = "<<",                          type = "literal"  },
    {
      pattern = "[%s]%*()[%w%d_]+",
      type = { "keyword", "keyword2" }
    },
    {
      pattern = "%*()[%w%d_]+",
      type = { "keyword", "literal" }
    },
    {
      pattern = "[%[%{]()%s*[%w%d]+%g+%s*():%s",
      type = { "operator", "keyword2", "operator" }
    },
    {
      pattern = "[%s][%w%d]+%g+%s*():%s",
      type = { "keyword2", "operator" }
    },
    {
      pattern = "[%w%d]+%g+%s*():%s",
      type = { "literal", "operator" }
    },
    { pattern = "0%d+",                        type = "number"   },
    { pattern = "0x%x+",                       type = "number"   },
    { pattern = "[%+%-]?%d+[,%.eE:%+%d]*%d+",  type = "number"   },
    { pattern = "[%*%|%!>%%]",                 type = "keyword"  },
    { pattern = "[%-:%?%*%{%}%[%]]",           type = "operator" },
    -- Everything else for keywords to work
    {
      pattern = "[%d%a_][%g_]*()[%]%},]",
      type = { "string", "operator" }
    },
    { pattern = "[%d%a_][%g_]*",               type = "string"   },
  },
  symbols = {
    ["true"]  = "number",
    ["false"] = "number",
    ["y"]     = "number",
    ["n"]     = "number"
  }
}
