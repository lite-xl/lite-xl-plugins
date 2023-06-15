-- mod-version:3
-- https://nixos.wiki/wiki/Overview_of_the_Nix_Language
local syntax = require "core.syntax"

local function merge_tables(a, b)
  for _, v in pairs(b) do
    table.insert(a, v)
  end
end

local default_symbols = {
  ["import"]   = "keyword2",
  ["with"]     = "keyword2",
  ["builtins"] = "keyword2",
  ["inherit"]  = "keyword2",
  ["assert"]   = "keyword2",
  ["let"]      = "keyword2",
  ["in"]       = "keyword2",
  ["rec"]      = "keyword2",
  ["if"]       = "keyword",
  ["else"]     = "keyword",
  ["then"]     = "keyword",
  ["true"]     = "literal",
  ["false"]    = "literal",
  ["null"]     = "literal",
}

local default_patterns = {}

local string_interpolation = {
  { pattern = {"%${", "}"}, type = "keyword2", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  { pattern = "[%S][%w]*", type = "string" },
}

merge_tables(default_patterns, {
  { pattern = "#.*",          type = "comment" },
  { pattern = {"/%*", "%*/"}, type = "comment" },
  { pattern = "-?%.?%d+",     type = "number"  },

  -- interpolation
  { pattern = {"%${", "}"}, type = "keyword2", syntax = {
    patterns = default_patterns,
    symbols = default_symbols,
  }},
  { pattern = {'"', '"', '\\'}, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = {},
  }},
  { pattern = {"''", "''"}, type = "string", syntax = {
    patterns = string_interpolation,
    symbols = {},
  }},

  -- operators
  { pattern = "[%+%-%?!>%*]", type = "operator" },
  { pattern = "/ ",           type = "operator" },
  { pattern = "< ",           type = "operator" },
  { pattern = "//",           type = "operator" },
  { pattern = "&&",           type = "operator" },
  { pattern = "%->",          type = "operator" },
  { pattern = "||",           type = "operator" },
  { pattern = "==",           type = "operator" },
  { pattern = "!=",           type = "operator" },
  { pattern = ">=",           type = "operator" },
  { pattern = "<=",           type = "operator" },

  -- paths (function because its not used otherwise)
  { pattern = "%.?%.?/[^%s%[%]%(%){};,:]+", type = "function" },
  { pattern = "~/[^%s%[%]%(%){};,:]+",      type = "function" },
  { pattern = {"<", ">"},                   type = "function" },

  -- every other symbol
  { pattern = "[%a%-%_][%w%-%_]*", type = "symbol" },
  { pattern = ";%.,:",             type = "normal" },
})

syntax.add {
  name = "Nix",
  files = {"%.nix$"},
  comment = "#",
  block_comment = {"/*", "*/"},
  patterns = default_patterns,
  symbols = default_symbols,
}
