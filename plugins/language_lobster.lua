-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Lobster",
  files = "%.lobster$",
  comment = "//",
  patterns = {
    { pattern = "//.-\n",                    type = "comment" },
    { pattern = { "/%*", "%*/" },            type = "comment" },

    { pattern = "struct%s()[%a_][%w_]*", type = {"keyword", "keyword2"} },
    { pattern = "class%s()[%a_][%w_]*",  type = {"keyword", "keyword2"} },
    { pattern = "import%s+from",         type = "keyword" },

    { pattern = { '"', '"', '\\' },      type = "string"  },
    { pattern = { "'", "'", '\\' },      type = "string"  },
    { pattern = { '"""', '"""' },         type = "string"   },
    { pattern = "0x%x+",                 type = "number"  },
    { pattern = "%d+[%d%.eE]*f?",        type = "number"  },
    { pattern = "%.?%d+f?",              type = "number"  },
    { pattern = "[%+%-=/%*%^%%<>!~|&]",  type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",      type = "function" },
    { pattern = "[%a_][%w_]*",           type = "symbol" },
  },
  symbols = {
    ["import"] = "keyword",
    ["def"] = "keyword",
    ["fn"] = "keyword",
    ["return"] = "keyword",
    ["program"] = "keyword",
    ["private"] = "keyword",
    ["resource"] = "keyword",

    -- not really keywords but provides control-flow constructs
    ["if"] = "keyword",
    ["for"] = "keyword",
    ["while"] = "keyword",
    ["else"] = "keyword",

    ["enum"] = "keyword",
    ["enum_flags"] = "keyword",

    ["int"] = "keyword2",
    ["float"] = "keyword2",
    ["string"] = "keyword2",
    ["any"] = "keyword2",
    ["void"] = "keyword2",

    ["is"] = "keyword",
    ["typeof"] = "keyword",
    ["var"] = "keyword",
    ["let"] = "keyword",
    ["pakfile"] = "keyword",
    ["switch"] = "keyword",
    ["case"] = "keyword",
    ["default"] = "keyword",
    ["namespace"] = "keyword",

    ["not"] = "operator",
    ["and"] = "operator",
    ["or"] = "operator",

    ["nil"] = "literal",
  },
}

