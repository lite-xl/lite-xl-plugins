-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax References
-- https://kotlinlang.org/docs/basic-syntax.html
-- https://kotlinlang.org/docs/keyword-reference.html

syntax.add {
  name = "Kotlin",
  files = { "%.kts?$", "%.klib$" },
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    { pattern = "//.*",                              type = "comment"  }, -- Comment, single-line
    { pattern = { "/%*", "%*/" },                    type = "comment"  }, -- Comment, multi-line
    { pattern = { '"', '"', '\\' },                  type = "string"   }, -- String, quotation marks
    { pattern = { "'", "'", '\\' },                  type = "string"   }, -- String, apices
    { pattern = "'\\x%x?%x?%x?%x'",                  type = "string"   }, -- Character hexadecimal escape sequence
    { pattern = "'\\u%x%x%x%x'",                     type = "string"   }, -- Character unicode escape sequence
    { pattern = "'\\?.'",                            type = "string"   }, -- Character literal
    { pattern = "-?0x%x+",                           type = "number"   }, -- ?
    { pattern = "-?%d+[%deE]*f?",                    type = "number"   }, -- ?
    { pattern = "-?%.?%d+f?",                        type = "number"   }, -- ?
    { regex   = [[\-\>(?=\s)]],                      type = "operator" }, -- Lambda
    { regex   = [[\.{2}\<?\s?(?=[\\-]?[a-z0-9])]],   type = "operator" }, -- Range operators
    { pattern = "[%+%-=/%*%^%%<>!~|&]",              type = "operator" }, -- Operators
    { regex   = [[\?(?=\.)]],                        type = "operator" }, -- ?. operator
    { pattern = "[%a_][%w_]*%f[(]",                  type = "function" }, -- Function/Method/Class
    { regex   = [[`[\w_\s]+`(?=\s*\()]],             type = "function" }, -- Test Method
    { regex   = [[let(?=\s\{)]],                     type = "function" }, -- ? operator
    { regex   = [[\?\:(?=\s?)]],                     type = "operator" }, -- elvis operator
    { regex   = [[this(?=\.?\@?)]],                  type = "keyword"  }, -- this keyword
    { pattern = "^%s*%@.+%)",                        type = "keyword2" }, -- Annotation (at line start)
    { regex   = [[\s*\@.+\)(?=\s+\w+)]],             type = "keyword2" }, -- Annotation (at line middle)
    { pattern = "%@%w+",                             type = "keyword2" }, -- Annotation (like: final @Nullable String something;)
    { pattern = "^import()%s+()[%w_.]+",             type = { "keyword", "normal", "normal" } },
    { pattern = "[A-Z][A-Z_%d]+%f[^a-zA-Z_%d]",      type = "keyword2" }, -- Constants
    { pattern = "[%a_][%w_]*",                       type = "symbol"   }, -- ?
    -- TODO: class references
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
