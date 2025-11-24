-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Handlebars",
  files = { "%.hbs$" },
  block_comment = { "{{<--", "--}}" },
  patterns = {
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%f[%s>].->",
        "<%s*/%s*[sS][cC][rR][iI][pP][tT]%s*>"
      },
      syntax = ".js",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][tT][yY][lL][eE]%f[%s>].->",
        "<%s*/%s*[sS][tT][yY][lL][eE]%s*>"
      },
      syntax = ".css",
      type = "function"
    },
    { pattern = { "{{!", "}}" },     type = "comment"  },
    {
      pattern = { "{{", "}}" },
      syntax = {
        patterns = {
          { pattern = { '"', '"', '\\' },        type = "string"   },
          { pattern = { "'", "'", '\\' },        type = "string"   },
          { pattern = "-?%d+[%d%.]*f?",          type = "number"   },
          { pattern = "-?%.?%d+f?",              type = "number"   },
          { pattern = "[%a_][%w_]*()=",        type = { "keyword", "operator" } },
          { pattern = "[#/]*[%a_][%w_]*",        type = "symbol" },
          { pattern = "[%.=]",                   type = "operator" }
        },
        symbols = {
          ["#if"] = "keyword2",
          ["/if"] = "keyword2",
          ["else"] = "keyword2",
          ["#unless"] = "keyword2",
          ["lookup"] = "keyword2",
          ["log"] = "keyword2",
          ["#each"] = "keyword2",
          ["#with"] = "keyword2",
          ["true"] = "number",
          ["false"] = "number"
        }
      },
      type = "keyword"
    },
    { pattern = { "<!%-%-", "%-%->" },     type = "comment"  },
    { pattern = { '%f[^>][^<]', '%f[{<]' }, type = "normal"   },
    { pattern = { '"', '"', '\\' },        type = "string"   },
    { pattern = { "'", "'", '\\' },        type = "string"   },
    { pattern = "0x[%da-fA-F]+",           type = "number"   },
    { pattern = "-?%d+[%d%.]*f?",          type = "number"   },
    { pattern = "-?%.?%d+f?",              type = "number"   },
    { pattern = "%f[^<]![%a_][%w_]*",      type = "keyword2" },
    { pattern = "%f[^<][%a_][%w_]*",       type = "function" },
    { pattern = "%f[^<]/[%a_][%w_]*",      type = "function" },
    { pattern = "[%a_][%w_]*",             type = "keyword"  },
    { pattern = "[/<>=]",                  type = "operator" },
  },
  symbols = {},
}
