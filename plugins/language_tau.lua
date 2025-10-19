-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Tau",
  files = { "%.tau$" },
  comment = "#",
  patterns = {
    { pattern = { '{', '}' },      type = "operator",               syntax = ".tau" },
    -- funtion declaration
    {
      pattern = { '%.?()[%a_][%w_]*()%s*=%s*()fn()%(', '%)%s*' },
      type = { "operator", "function", "operator", "keyword", "normal" },
      syntax = {
        patterns = {
          { pattern = '[%a_][%w_]*', type = "literal" },
        },
        symbols = {
          [','] = "normal",
        },
      },
    },
    -- strings
    { pattern = { "`", "`" },     type = "string" },
    { pattern = { '\\"', '\\"' }, type = "string" },
    {
      pattern = { '"', '"', '\\' },
      type    = "string",
      syntax  = {
        -- TODO: formatted strings has still some issues with inner {} blocks like if { .. } else { ... }  and escaped \"strings\"
        patterns = {
          { pattern = { '{', '}' }, type = "operator", syntax = ".tau" },
          { pattern = '[^%s"]+',    type = "string"                    },
        },
        symbols = {},
      },
    },

    -- numbers and values
    { pattern = "0b[01]{0,64}",       type = "number"   },
    { pattern = "0o[0-7]{0,24}",      type = "number"   },
    { pattern = "0x[%da-fA-F]{0,16}", type = "number"   },
    { pattern = "-?%d{0,20}",         type = "number"   },
    { pattern = "-?%d+[%d%.eE]*",     type = "number"   },
    { pattern = "-?%.?%d+",           type = "number"   },

    -- others
    { pattern = "[%+%-=/%*%^%%<>!~|&]",  type = "operator"                 },
    { pattern = "%.?()[%a_][%w_]*%f[(]", type = { "operator", "function" } },
    { pattern = "%.()[%a_][%w_]*",       type = { "operator", "literal" }  },
    { pattern = "[%a_][%w_]*",           type = "symbol"                   },
  },
  symbols = {
    -- actual keywords
    ["if"]        = "keyword",
    ["else"]      = "keyword",
    ["for"]       = "keyword",
    ["break"]     = "keyword",
    ["continue"]  = "keyword",
    ["tau"]       = "keyword",
    ["fn"]        = "keyword",
    ["return"]    = "keyword",

    -- literal values
    ["true"]      = "literal",
    ["false"]     = "literal",
    ["null"]      = "literal",

    -- builtin functions
    ["new"]       = "keyword2",
    ["len"]       = "keyword2",
    ["println"]   = "keyword2",
    ["print"]     = "keyword2",
    ["input"]     = "keyword2",
    ["string"]    = "keyword2",
    ["error"]     = "keyword2",
    ["type"]      = "keyword2",
    ["int"]       = "keyword2",
    ["float"]     = "keyword2",
    ["exit"]      = "keyword2",
    ["append"]    = "keyword2",
    ["newfailed"] = "keyword2",
    ["plugin"]    = "keyword2",
    ["pipesend"]  = "keyword2",
    ["recv"]      = "keyword2",
    ["close"]     = "keyword2",
    ["hex"]       = "keyword2",
    ["oct"]       = "keyword2",
    ["bin"]       = "keyword2",
    ["slice"]     = "keyword2",
    ["keys"]      = "keyword2",
    ["delete"]    = "keyword2"
  },
}

