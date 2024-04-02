-- mod-version:3

-- https://kotlinlang.org/docs/keyword-reference.html#hard-keywords

local syntax = require "core.syntax"

syntax.add {
  name = "Kotlin",
  files = { "%.kt$" },
  comment = "//",
  patterns = {
    { pattern = "//.*",               type = "comment"  }, -- Comment, single-line
    { pattern = { "/%*", "%*/" },       type = "comment"  }, -- Comment, multi-line
    { pattern = { '"', '"', '\\' },     type = "string"   }, -- String, quotation marks
    { pattern = { "'", "'", '\\' },     type = "string"   }, -- String, apices
    { pattern = "'\\x%x?%x?%x?%x'",     type = "string"   }, -- Character hexadecimal escape sequence
    { pattern = "'\\u%x%x%x%x'",        type = "string"   }, -- Character unicode escape sequence
    { pattern = "'\\?.'",               type = "string"   }, -- Character literal
    { pattern = "-?0x%x+",              type = "number"   }, -- ?
    { pattern = "-?%d+[%d%.eE]*f?",     type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",           type = "number"   }, -- ?
    { regex = "\\-\\>(?=\\s)",          type = "keyword" },  -- lambdas
    { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" }, -- Operators
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" }, -- Function/Method/Class/... name
    { regex = "\\$(?=[a-zA-Z]+)",       type = "string" },   -- ?
    { regex = "\\@[a-zA-Z]+",           type = "string" },   -- Annotations
    { regex = "this(?=\\.)",            type = "keyword" },  -- this keyword
    { regex = "[A-Z]+_?[A-Z]+",         type = "keyword2" }, -- Constants, FULL UPPERCASE
    -- FIX: stricter number match, careful about .1
    -- FIX: .. and ..< are operators
  },
  symbols = {
    -- Hard keywords
    ["as"]           = "keyword",
    ["break"]        = "keyword",
    ["class"]        = "keyword",
    ["continue"]     = "keyword",
    ["do"]           = "keyword",
    ["else"]         = "keyword",
    ["for"]          = "keyword",
    ["fun"]          = "keyword",
    ["if"]           = "keyword",
    ["in"]           = "keyword",
    ["!in"]          = "keyword",
    ["interface"]    = "keyword",
    ["is"]           = "keyword",
    ["!is"]          = "keyword",
    ["object"]       = "keyword",
    ["package"]      = "keyword",
    ["return"]       = "keyword",
    ["super"]        = "keyword",
    ["this"]         = "keyword",
    ["throw"]        = "keyword",
    ["try"]          = "keyword",
    ["typealias"]    = "keyword",
    ["typeof"]       = "keyword",
    ["val"]          = "keyword",
    ["var"]          = "keyword",
    ["when"]         = "keyword",
    ["while"]        = "keyword",

    -- Soft keywords
    ["by"]           = "keyword",
    ["catch"]        = "keyword",
    ["constructor"]  = "keyword",
    ["delegate"]     = "keyword",
    ["dynamic"]      = "keyword",
    ["field"]        = "keyword",
    ["file"]         = "keyword",
    ["finally"]      = "keyword",
    ["get"]          = "keyword",
    ["import"]       = "keyword",
    ["init"]         = "keyword",
    ["param"]        = "keyword",
    ["property"]     = "keyword",
    ["receiver"]     = "keyword",
    ["set"]          = "keyword",
    ["setparam"]     = "keyword",
    ["value"]        = "keyword",
    ["where"]        = "keyword",

    -- Modifier keywords
    ["abstract"]     = "keyword",
    ["actual"]       = "keyword",
    ["annotation"]   = "keyword",
    ["companion"]    = "keyword",
    ["const"]        = "keyword",
    ["crossinline"]  = "keyword",
    ["data"]         = "keyword",
    ["enum"]         = "keyword",
    ["expect"]       = "keyword",
    ["external"]     = "keyword",
    ["final"]        = "keyword",
    ["inline"]       = "keyword",
    ["inner"]        = "keyword",
    ["infix"]        = "keyword",
    ["internal"]     = "keyword",
    ["lateinit"]     = "keyword",
    ["noinline"]     = "keyword",
    ["open"]         = "keyword",
    ["operator"]     = "keyword",
    ["out"]          = "keyword",
    ["override"]     = "keyword",
    ["private"]      = "keyword",
    ["protected"]    = "keyword",
    ["public"]       = "keyword",
    ["reified"]      = "keyword",
    ["sealed"]       = "keyword",
    ["suspend"]      = "keyword",
    ["tailrec"]      = "keyword",
    ["vararg"]       = "keyword",

    -- Special identifiers
    ["it"]           = "keyword",

    -- Boolean
    ["true"]         = "literal",
    ["false"]        = "literal",
    ["null"]         = "literal",
  },
}
