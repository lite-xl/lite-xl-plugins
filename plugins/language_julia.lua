-- mod-version:3
-- Support for the Julia programming language:
-- Covers the most used keywords up to Julia version 1.6.4

local syntax = require "core.syntax"


local jlstr = {

  patterns = {
    { pattern = { "%$", "%f[^%w%(%)_%.]" },  type = "operator",  syntax = ".jl" },
    { pattern = "\\.",                 type = "string"                    },
    { pattern = '[^"\\%$\']+',         type = "string"                    }

  },

  symbols = {}
}


syntax.add {
  name = "Julia",
  files = { "%.jl$" },
  comment = "#",

  patterns = {

    { pattern = { "#=", "=#" },              type = "comment"                 },
    { pattern = "#.*$",                      type = "comment"                 },
    { pattern = { "%(", "%)" },                               syntax = ".jl"  },

    { pattern = { 'icxx"""', '"""', "\\" },  type = "string", syntax = ".cpp" },
    { pattern = { 'cxx"""',  '"""', "\\" },  type = "string", syntax = ".cpp" },
    { pattern = { 'py"""',   '"""', "\\" },  type = "string", syntax = ".py"  },
    { pattern = { 'js"""',   '"""', "\\" },  type = "string", syntax = ".js"  },
    { pattern = { 'md"""',   '"""', "\\" },  type = "string", syntax = ".md"  },

    { pattern = "0[oO_][0-7]+",              type = "number"                  },
    { pattern = "0[xb][%x_]+",               type = "number"                  },
    { pattern = "%.?%d+[%d%.eE_]*f?",        type = "number"                  },
    { pattern = "%f[-%w_]-%f[%d%.]",         type = "number"                  },

    { pattern = ":[%a_][%w_]*",              type = "function"                },
    { pattern = "[%a_][%w_]*[.!]?%f[(]",     type = "function"                },
    { pattern = "@[%a_][%w_]+",              type = "function"                },

    { pattern = { '"""',     '"""', "\\" },  type = "string",  syntax = jlstr },
    { pattern = { 'r"',      '""',  "\\" },  type = "string"                  },
    { pattern = { '[bvL]?"', '"',   "\\" },  type = "string",  syntax = jlstr },
    { pattern = { "`",       "`",   "\\" },  type = "string",  syntax = jlstr },
    { pattern = { "'\\",     "'",   "\\" },  type = "string"                  },
    { pattern = "'.'",                       type = "string",                 },

    { pattern = "%.?[%+%-=/%*%^%%<>!~|&:]",  type = "operator"                },
    { pattern = "[%a_][%w_]*",               type = "symbol"                  },
  },


  symbols = {
    -- keywords
    ["baremodule"]   = "keyword",
    ["begin"]        = "keyword",
    ["break"]        = "keyword",
    ["catch"]        = "keyword",
    ["const"]        = "keyword",
    ["continue"]     = "keyword",
    ["do"]           = "keyword",
    ["Dict"]         = "keyword",
    ["Set"]          = "keyword",
    ["Union"]        = "keyword",
    ["else"]         = "keyword",
    ["elseif"]       = "keyword",
    ["end"]          = "keyword",
    ["export"]       = "keyword",
    ["finally"]      = "keyword",
    ["for"]          = "keyword",
    ["function"]     = "keyword",
    ["global"]       = "keyword",
    ["if"]           = "keyword",
    ["in"]           = "keyword",
    ["import"]       = "keyword",
    ["let"]          = "keyword",
    ["local"]        = "keyword",
    ["macro"]        = "keyword",
    ["type"]         = "keyword",
    ["module"]       = "keyword",
    ["mutable"]      = "keyword",
    ["quote"]        = "keyword",
    ["return"]       = "keyword",
    ["try"]          = "keyword",
    ["typeof"]       = "keyword",
    ["using"]        = "keyword",
    ["while"]        = "keyword",
    ["where"]        = "keyword",

    -- types
    ["struct"]       = "keyword2",
    ["abstract"]     = "keyword2",
    ["primitive"]    = "keyword2",
    ["Char"]         = "keyword2",
    ["Bool"]         = "keyword2",
    ["Int"]          = "keyword2",
    ["Integer"]      = "keyword2",
    ["Int8"]         = "keyword2",
    ["UInt8"]        = "keyword2",
    ["Int16"]        = "keyword2",
    ["UInt16"]       = "keyword2",
    ["Int32"]        = "keyword2",
    ["UInt32"]       = "keyword2",
    ["Int64"]        = "keyword2",
    ["UInt64"]       = "keyword2",
    ["Int128"]       = "keyword2",
    ["UInt128"]      = "keyword2",
    ["Float16"]      = "keyword2",
    ["Float32"]      = "keyword2",
    ["Float64"]      = "keyword2",
    ["Vector"]       = "keyword2",
    ["Matrix"]       = "keyword2",
    ["Ref"]          = "keyword2",
    ["String"]       = "keyword2",
    ["Function"]     = "keyword2",
    ["Number"]       = "keyword2",
    ["im"]           = "keyword2",

    -- literals
    ["missing"]      = "literal",
    ["true"]         = "literal",
    ["false"]        = "literal",
    ["nothing"]      = "literal",
    ["Inf"]          = "literal",
    ["NaN"]          = "literal",
  }
}
