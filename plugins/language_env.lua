-- mod-version:3

local syntax = require "core.syntax"

local key_pattern = '[a-zA-Z_]+[a-zA-Z0-9_]*'
local unicode_sequence = "'?\\u%x%x%x%x'?"
local escaped_literals = "\\[nrtfb\\\"']"
local null_pattern = '%s*[Nn][Uu][Ll][Ll]%s*'
local true_pattern = '%s*[Tt][Rr][Uu][Ee]%s*'
local false_pattern = '%s*[Ff][Aa][Ll][Ss][Ee]%s*'

local synt_key = {
  symbols = {},
  patterns = {
    { type = "keyword2", pattern = key_pattern },
  },
}

local synt_dqs = {
  symbols = {},
  patterns = {
    { pattern = { "%${", "}" },     type = "keyword", syntax = synt_key },
    { pattern = "0[bB][%d]+",       type = "number"   },
    { pattern = "0[xX][%da-fA-F]+", type = "number"   },
    { pattern = "[-+]?%.?%d+",      type = "number"   },
    { pattern = escaped_literals,   type = "literal"  }, -- escaped chars
    { pattern = unicode_sequence,   type = "literal"  }, -- unicode sequence
    { pattern = '[%w%p%s]',         type = "string"   },
  },
}

syntax.add {
  name = "language_env",
  files = { "%.env$" },
  comment = '#',
  symbols = {},
  patterns = {
    { pattern = "#.*$",           type = "comment"  },
    { pattern = "export",         type = "function" },
    { pattern = null_pattern,     type = "literal"  },
    { pattern = true_pattern,     type = "literal"  },
    { pattern = false_pattern,    type = "literal"  },
    { pattern = escaped_literals, type = "literal"  },
    { pattern = unicode_sequence, type = "literal"  },
    -- interpolation
    { pattern = { "%${", "}" },     type = "keyword", syntax = synt_key },
    -- numbers
    { pattern = "0[bB][%d]+",       type = "number" },
    { pattern = "0[xX][%da-fA-F]+", type = "number" },
    { pattern = "[-+]?%.?%d+",      type = "number" },
    -- keys
    { pattern = '[\'"].*[\'"]%s*=.*',     type = "normal" },
    -- {
    --   pattern = '[\'"]?'..escaped_literals..'[\'"]?%s*=.*',
    --   type = "normal"
    -- },
    -- {
    --   pattern = '[\'"]?'..null_pattern..'[\'"]?%s*=.*',
    --   type = "normal"
    -- },
    { pattern = key_pattern..'%s*()=%s*', type = { "keyword2", "operator" }},
    -- quoted strings
    { pattern = {'"', '"', '\\'},     type = "string",  syntax = synt_dqs},
    { pattern = {"'", "'", '\\'},     type = "string"   },
    { pattern = {'"""', '"""', '\\'}, type = "string"   },
    { pattern = {"'''", "'''", '\\'}, type = "string"   },
  },
}
