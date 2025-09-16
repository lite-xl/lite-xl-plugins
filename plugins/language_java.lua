-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax References
-- https://docs.oracle.com/javase/specs/jls/se8/html/index.html

-- WIP: required for complex recurring patterns


syntax.add {
  name = "Java",
  files = { "%.java$" },
  comment = "//",
  patterns = {
    { pattern = "//.*",                                       type = "comment"  }, -- Single-line comment
    { pattern = { "/%*", "%*/" },                             type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                           type = "string"   }, -- String
    { pattern = { "'", "'", '\\' },                           type = "string"   }, -- String
    { pattern = "'\\x%x?%x?%x?%x'",                           type = "string"   }, -- character hexadecimal escape sequence
    { pattern = "'\\u%x%x%x%x'",                              type = "string"   }, -- character unicode escape sequence
    { pattern = "'\\?.'",                                     type = "string"   }, -- character literal
    { pattern = "-?0x%x+",                                    type = "number"   }, -- Number: hexadecimal
    { pattern = "-?%d+[%d%.eE]*[fFdD]?",                      type = "number"   }, -- Number: exponential, float/double
    { pattern = "[%+%-=/%*%^%%<>!~|&]",                       type = "operator" }, -- Operator
    -- Method
    { pattern = "[A-Z_]+[a-z-A-Z_]+()%s+()%w+()%f[(]",        type = { "function", "normal", "function", "normal" } },
    { pattern = "[A-Z_]+[a-z-A-Z_]+()%<.-%>()%s+()%w+()%f[(]",type = { "function", "keyword2", "normal", "function", "normal" } },
    { pattern = "[%a_][%w_]*%f[(]",                           type = "function" },
    -- Generic method
    { pattern = "%s+()%<.-%>()%s+", type = { "normal", "keyword2", "normal" } },
    { pattern = "%.()%<.-%>()%w+", type = { "normal", "keyword2", "function" } },
    -- Import
    { pattern = "^import()%s+()[%w_.]+",                      type = { "keyword", "normal", "normal" } },
    -- Constants
    { pattern = "[A-Z][A-Z_%d]+%f[^a-zA-Z_%d]",               type = "keyword2" },
    -- Class name reference: ; (single accessibility modifier)
    { pattern = "return()%s()[a-z][%w_]+()%;",                type = { "symbol", "normal", "normal", "normal" } }, -- This is a fix: es. return someVarName;
    { pattern = "return()%s()[A-Z][A-Z_]+()%;",               type = { "symbol", "normal", "keyword2", "normal" } },
    { pattern = "^%s*[A-Z]%w+%s+()%w+%s*%;",                  type = { "function", "normal" } },
    { pattern = "^%s*%w+()%<.-%>()%s+%w+%s*%;",               type = { "function", "keyword2", "normal" } },
    -- Class name reference: ; (multiple accessibility modifiers)
    { pattern = "%s*[A-Z]%w+%s+()[A-Z_]+()%s*%;",             type = { "function", "keyword2", "normal" } },
    { pattern = "%s*[A-Z]%w+()%<.-%>()%s+[A-Z_]+()%s*%;",     type = { "function", "keyword2", "keyword2", "normal" } },
    { pattern = "%s*[A-Z]%w+%s+()[%w_]+%s*%;",                type = { "function", "normal" } },
    { pattern = "%s*[A-Z]%w+()%<.-%>()%s+[%w_]+%s*%;",        type = { "function", "keyword2", "normal" } },
    -- es. private String classBlacklistRegexp;
    -- es. private String<> classBlacklistRegexp;
    -- es. private String<SomeClass> classBlacklistRegexp;
    { pattern = "^%s*%w+%s+()%w+()%<.-%>()%s*%w+%s*%;",       type = { "keyword", "function", "keyword2", "normal" } },
    { pattern = "^%s*%w+%s+()%w+%s*()%w+%s*%;",               type = { "keyword", "function", "normal" } },
    -- Class name reference: =
    { pattern = "%w+%s+()[A-Z_]+%s*()%=",                     type = { "function", "keyword2", "operator" } },
    { pattern = "%w+()%<.-%>()%s+[A-Z_]+%s*()%=",             type = { "function", "keyword2", "keyword2", "operator" } },
    { pattern = "%w+%s+()%w+%s*()%=",                         type = { "function", "normal", "operator" } },
    { pattern = "%w+()%<.-%>()%s+%w+%s*()%=",                 type = { "function", "keyword2", "normal", "operator" } },
    -- Class name reference: new
    { pattern = "new()%s+%w+()%<.-%>()%f[(]",                 type = { "keyword", "function", "keyword2", "normal" } },
    { pattern = "new()%s+%w+()%f[(]",                         type = { "keyword", "function", "normal" } },
    -- Class name reference: ( then ,
    { pattern = "%(%s*()%w+%s+()%w+%s*%,",                    type = { "normal", "function", "normal" } },
    { pattern = "%(%s*()%w+()%<.-%>()%s+%w+%s*%,",            type = { "normal", "function", "keyword2", "normal" } },
    -- Class name reference: (final then ,
    { pattern = "%(%s*()final%s*()%w+()%<.-%>()%s+%w+%s*%,",  type = { "normal", "keyword", "function", "keyword2", "normal" } },
    { pattern = "%(%s*()final%s*()%w+%s+()%w+%s*%,",          type = { "normal", "keyword", "function", "normal" } },
    -- Class name reference: , then ,
    { pattern = "%s*()%w+%s+()%w+%s*%,",                      type = { "normal", "function", "normal" } },
    { pattern = "%s*()%w+()%<.-%>()%s+%w+%s*%,",              type = { "normal", "function", "keyword2", "normal" } },
    -- Class name reference: , then )
    { pattern = "%s*()%w+()%s+%w+%s*%)",                      type = { "normal", "function", "normal" } },
    { pattern = "%s*()%w+()%<.-%>()%s+%w+%s*%)",              type = { "normal", "function", "keyword2", "normal" } },
    -- Class name reference: ( then )
    { pattern = "%(%s*()%w+%s+()%w+%s*%)",                    type = { "normal", "function", "normal" } },
    { pattern = "%(%s*()%w+()%<.-%>()%s+()%w+%s*%)",          type = { "normal", "function", "keyword2", "normal", "normal" } },
    -- Array
    { pattern = "%w+()%[()%d*()%]",                           type = { "function", "normal", "number", "normal" } },
    -- FIX: ?
    { pattern = "this()%s*.*$",                               type = { "keyword", "normal" } },
    -- Annotation (like: final @Nullable String something;)
    { pattern = "%@%w+",                                      type = "keyword2" },
    -- Method reference with double colon operator
    { pattern = "%:%:()%w+",                                  type = { "normal", "function" } },
    -- .class should be colored as normal
    { pattern = "%.class",                                    type = "normal"   },
    -- Symbols
    { pattern = "[%a_][%w_]*",                                type = "symbol"   },
    -- WIP: check for missing syntaxes by opening an example Java project
    -- TODO: check if there are redundant/overlapping patterns
    -- TODO: , final BiomeDictionary.Type... types) {
  },
  symbols = {
    ["abstract"]      = "keyword",
    ["assert"]        = "keyword",
    ["break"]         = "keyword",
    ["case"]          = "keyword",
    ["catch"]         = "keyword",
    ["class"]         = "keyword",
    ["const"]         = "keyword",
    ["continue"]      = "keyword",
    ["default"]       = "keyword",
    ["do"]            = "keyword",
    ["else"]          = "keyword",
    ["enum"]          = "keyword",
    ["extends"]       = "keyword",
    ["final"]         = "keyword",
    ["finally"]       = "keyword",
    ["for"]           = "keyword",
    ["if"]            = "keyword",
    ["goto"]          = "keyword",
    ["implements"]    = "keyword",
    ["import"]        = "keyword",
    ["instanceof"]    = "keyword",
    ["interface"]     = "keyword",
    ["native"]        = "keyword",
    ["new"]           = "keyword",
    ["package"]       = "keyword",
    ["permits"]       = "keyword",
    ["private"]       = "keyword",
    ["protected"]     = "keyword",
    ["public"]        = "keyword",
    ["record"]        = "keyword",
    ["return"]        = "keyword",
    ["sealed"]        = "keyword",
    ["static"]        = "keyword",
    ["strictfp"]      = "keyword",
    ["super"]         = "keyword",
    ["switch"]        = "keyword",
    ["synchronized"]  = "keyword",
    ["this"]          = "keyword",
    ["throw"]         = "keyword",
    ["throws"]        = "keyword",
    ["transient"]     = "keyword",
    ["try"]           = "keyword",
    ["var"]           = "keyword",
    ["void"]          = "keyword",
    ["volatile"]      = "keyword",
    ["while"]         = "keyword",
    ["yield"]         = "keyword",

    ["boolean"]       = "keyword2",
    ["byte"]          = "keyword2",
    ["char"]          = "keyword2",
    ["double"]        = "keyword2",
    ["float"]         = "keyword2",
    ["int"]           = "keyword2",
    ["long"]          = "keyword2",
    ["short"]         = "keyword2",

    ["true"]     = "literal",
    ["false"]    = "literal",
    ["null"]     = "literal"
  }
}
