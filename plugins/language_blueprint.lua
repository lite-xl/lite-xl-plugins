-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Blueprint",
  files = { "%.blp$", },
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {

    -- Comments
    { pattern = "//.*", type = "comment" },
    { pattern = { "/%*", "%*/" }, type = "comment" },

    -- Strings
    { pattern = { "'", "'", "\\"}, type = "string" },
    { pattern = { '"', '"', "\\" }, type = "string" },

    -- Numbers
    { pattern = "%.?%d+", type = "number" },

    -- Child type
    { pattern = "%[.*%]", type = "literal" },

    -- Operators
    { pattern = "%$", type = "operator" },
    { pattern = "=>%s*%$().*()%(%)", type = { "operator", "function", "normal" } },

    -- Properties
    { pattern = "[%w-_]+()%s*:", type = { "keyword", "normal" } },

    -- Classes
    { pattern = "[%w_-%.]+%s*(){", type = { "keyword2", "normal"} },
    { pattern = "[%w_-%.]+%s*()[%w_-]+%s*{", type = { "keyword2", "normal"} },

    -- Symbols
    { pattern = "[%w-_]+", type = "symbol" },

  },
  symbols = {
    ["true"] = "literal",
    ["false"] = "literal",
    ["null"] = "literal",

    -- Import statements
    ["using"] = "keyword",

    -- Keywords
    ["after"] = "keyword",
    ["bidirectional"] = "keyword",
    ["bind-property"] = "keyword",
    ["bind"] = "keyword",
    ["default"] = "keyword",
    ["destructive"] = "keyword",
    ["disabled"] = "keyword",
    ["inverted"] = "keyword",
    ["no-sync-create"] = "keyword",
    ["suggested"] = "keyword",
    ["swapped"] = "keyword",
    ["sync-create"] = "keyword",
    ["template"] = "keyword",

    -- Menus
    ["menu"] = "keyword",
    ["submenu"] = "keyword",
    ["section"] = "keyword",

    -- Nested blocks
    ["responses"] = "keyword2",
    ["items"] = "keyword2",
    ["mime-types"] = "keyword2",
    ["patterns"] = "keyword2",
    ["suffixes"] = "keyword2",
    ["marks"] = "keyword2",
    ["widgets"] = "keyword2",
    ["strings"] = "keyword2",
    ["styles"] = "keyword2",
    ["accessibility"] = "keyword2",
    ["setters"] = "keyword2",
    ["layout"] = "keyword2",
    ["item"] = "keyword2",
    ["condition"] = "keyword2",
    ["mark"] = "keyword2",

    -- Translated strings
    ["_"] = "operator",
    ["C_"] = "operator",
  }
}

