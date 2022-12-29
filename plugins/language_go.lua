-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Go",
  files = { "%.go$" },
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {
    { pattern = "//.-\n",               type = "comment"  },
    { pattern = { "/%*", "%*/" },       type = "comment"  },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "`", "`", '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = "0[oO_][0-7]+i?",       type = "number"   },
    { pattern = "-?0x[%x_]+i?",         type = "number"   },
    { pattern = "-?%d+_%di?",           type = "number"   },
    { pattern = "-?%d+[%d%.eE]*f?i?",   type = "number"   },
    { pattern = "-?%.?%d+f?i?",         type = "number"   },
    -- goto label
    { pattern = "^%s+()[%a_][%w%_]*()%s*:%s$", -- this is to fix `default:`
      type = { "normal", "function", "normal" }
    },
    { pattern = "^%s*[%a_][%w%_]*()%s*:%s$",
      type = { "function", "normal" }
    },
    -- pointer, generic and reference type
    { pattern = "[%*~&]()[%a_][%w%_]*",
      type = { "operator", "keyword2" }
    },
    -- slice type
    { pattern = "%[%]()[%a_][%w%_]*",
      type = { "operator", "keyword2" }
    },
    -- type coerce
    {
      pattern = "%.%(()[%a_][%w_]*()%)",
      type = { "normal", "keyword2", "normal" }
    },
    -- struct literal
    { pattern = "[%a_][%w%_]*()%s*{%s*",
      type = { "keyword2", "normal" }
    },
    -- operators
    { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" },
    { pattern = ":=",                   type = "operator" },
    -- function calls
    { pattern = "func()%s*[%a_][%w_]*()%f[%[(]", -- function statement
      type = {"keyword", "function", "normal"}
    },
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
    { pattern = "%.()[%a_][%w_]*%f[(]",
      type = { "normal", "function" }
    },
    -- type declaration
    { pattern = "type()%s+()[%a_][%w%_]*",
      type = { "keyword", "normal", "keyword2" }
    },
    -- variable declaration
    { pattern = "var()%s+()[%a_][%w%_]*",
      type = { "keyword", "normal", "symbol" }
    },
    -- goto
    { pattern = "goto()%s+()[%a_][%w%_]*",
      type = { "keyword", "normal", "function" }
    },
    -- if fix
    { pattern = "if()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- for fix
    { pattern = "for()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- return fix
    { pattern = "return()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- range fix
    { pattern = "range()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- func fix
    { pattern = "func()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- switch fix
    { pattern = "switch()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- case fix
    { pattern = "case()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- break fix
    { pattern = "break()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- continue fix
    { pattern = "continue()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- package fix
    { pattern = "package()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- go fix
    { pattern = "go()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- chan fix
    { pattern = "chan()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- defer fix
    { pattern = "defer()%s+%f[%a_]",
      type = { "keyword", "normal" }
    },
    -- field declaration
    { pattern = "[%a_][%w%_]*()%s*():%s*%f[%w%p]",
      type = { "function", "normal", "operator" }
    },
    -- parameters or declarations
    { pattern = "[%a_][%w%_]*()%s+()[%*~&]?()[%a_][%w%_]*",
      type = { "literal", "normal", "operator", "keyword2" }
    },
    { pattern = "[%a_][%w_]*()%s+()%[%]()[%a_][%w%_]*",
      type = { "literal", "normal", "normal", "keyword2" }
    },
    -- single return type
    {
      pattern = "%)%s+%(?()[%a_][%w%_]*()%)?%s+%{",
      type = { "normal", "keyword2", "normal" }
    },
    -- sub fields
    { pattern = "%.()[%a_][%w_]*",
      type = { "normal", "literal" }
    },
    -- every other symbol
    { pattern = "[%a_][%w_]*",          type = "symbol"   },
  },
  symbols = {
    ["if"]          = "keyword",
    ["else"]        = "keyword",
    ["elseif"]      = "keyword",
    ["for"]         = "keyword",
    ["continue"]    = "keyword",
    ["return"]      = "keyword",
    ["struct"]      = "keyword",
    ["switch"]      = "keyword",
    ["case"]        = "keyword",
    ["default"]     = "keyword",
    ["const"]       = "keyword",
    ["package"]     = "keyword",
    ["import"]      = "keyword",
    ["func"]        = "keyword",
    ["var"]         = "keyword",
    ["type"]        = "keyword",
    ["interface"]   = "keyword",
    ["select"]      = "keyword",
    ["break"]       = "keyword",
    ["range"]       = "keyword",
    ["chan"]        = "keyword",
    ["defer"]       = "keyword",
    ["go"]          = "keyword",
    ["fallthrough"] = "keyword",
    ["goto"]        = "keyword",
    ["iota"]        = "keyword2",
    ["int"]         = "keyword2",
    ["int64"]       = "keyword2",
    ["int32"]       = "keyword2",
    ["int16"]       = "keyword2",
    ["int8"]        = "keyword2",
    ["uint"]        = "keyword2",
    ["uint64"]      = "keyword2",
    ["uint32"]      = "keyword2",
    ["uint16"]      = "keyword2",
    ["uint8"]       = "keyword2",
    ["uintptr"]     = "keyword2",
    ["float64"]     = "keyword2",
    ["float32"]     = "keyword2",
    ["map"]         = "keyword2",
    ["string"]      = "keyword2",
    ["rune"]        = "keyword2",
    ["bool"]        = "keyword2",
    ["byte"]        = "keyword2",
    ["error"]       = "keyword2",
    ["complex64"]   = "keyword2",
    ["complex128"]  = "keyword2",
    ["true"]        = "literal",
    ["false"]       = "literal",
    ["nil"]         = "literal",
  },
}

syntax.add {
  name = "Go",
  files = { "go%.mod" },
  comment = "//",
  patterns = {
    { pattern = "//.-\n", type = "comment"},
    { pattern = "module() %S+()",
      type = { "keyword", "string", "normal"}
    },
    { pattern = "go() %S+()",
      type = { "keyword", "string", "normal" }
    },
    { pattern = "%S+() v%S+()",
      type = { "string", "keyword", "normal" }
    },
  },
  symbols = {
    ["require"] = "keyword",
    ["module"]  = "keyword",
    ["go"]      = "keyword",
  }
}

syntax.add {
  name = "Go",
  files = { "go%.sum" },
  patterns = {
    { pattern = "%S+() v[^/]-() h1:()%S+()=",
      type = { "string", "keyword", "normal", "string", "normal" }
    },
    { pattern = "%S+() v[^/]-()/%S+() h1:()%S+()=",
      type = { "string", "keyword", "string", "normal", "string", "normal" }
    },
  },
  symbols = {}
}

