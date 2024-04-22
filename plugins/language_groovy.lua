-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Groovy",
  files = { "%.groovy$" },
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    { pattern = "//.*",                          type = "comment"  }, -- Single-line comment
    { pattern = { "/%*", "%*/" },                type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },              type = "string"   }, -- String, double quotes
    { pattern = { "'", "'", '\\' },              type = "string"   }, -- String, apices
    { pattern = { "%/", "%/", '\\' },            type = "string"   }, -- Slashy string
    { pattern = { "%$%/", "%/%$", '\\' },        type = "string"   }, -- Dollar slashy string
    { pattern = "'\\x%x?%x?%x?%x'",              type = "string"   }, -- character hexadecimal escape sequence
    { pattern = "'\\u%x%x%x%x'",                 type = "string"   }, -- character unicode escape sequence
    { pattern = "'\\?.'",                        type = "string"   }, -- character literal
    { pattern = "-?0x%x+",                       type = "number"   }, -- ?
    { pattern = "-?%d+[%d%.eE]*[a-zA-Z]?",       type = "number"   }, -- ?
    { pattern = "-?%.?%d+",                      type = "number"   }, -- ?
    { pattern = "-?[%d_+]+[a-zA-Z]?",            type = "number"   }, -- ?
    { pattern = "[%+%-=/%*%^%%<>!~|&]",          type = "operator" }, -- Operators
    { pattern = "[%a_][%w_]*%f[(]",              type = "function" }, -- Function/Class/Method/...
    { pattern = "[%a_][%w_]*%f[%[]",             type = "function" }, -- Custom Type
    { regex   = "[A-Z]+_?[A-Z]+",                type = "keyword2" }, -- Constants
    { pattern = "import()%s+()[%w_.]+",          type = { "keyword", "normal", "normal" } },
    { pattern = "[%a_][%w_]*",                   type = "symbol"   }, -- ?
    { pattern = "[a-zA-Z]+%.+",                  type = "function" }, -- Lib path
    -- TODO: .class.
  },
  symbols = {
    -- Reserved keywords
    ["abstract"]           = "keyword",
    ["assert"]             = "keyword",
    ["break"]              = "keyword",
    ["case"]               = "keyword",
    ["catch"]              = "keyword",
    ["class"]              = "keyword",
    ["const"]              = "keyword",
    ["continue"]           = "keyword",
    ["def"]                = "keyword",
    ["default"]            = "keyword",
    ["do"]                 = "keyword",
    ["else"]               = "keyword",
    ["enum"]               = "keyword",
    ["extends"]            = "keyword",
    ["final"]              = "keyword",
    ["finally"]            = "keyword",
    ["for"]                = "keyword",
    ["goto"]               = "keyword",
    ["if"]                 = "keyword",
    ["implements"]         = "keyword",
    ["import"]             = "keyword",
    ["instanceof"]         = "keyword",
    ["interface"]          = "keyword",
    ["native"]             = "keyword",
    ["new"]                = "keyword",
    ["non-sealed"]         = "keyword",
    ["package"]            = "keyword",
    ["public"]             = "keyword",
    ["protected"]          = "keyword",
    ["private"]            = "keyword",
    ["return"]             = "keyword",
    ["static"]             = "keyword",
    ["strictfp"]           = "keyword",
    ["super"]              = "keyword",
    ["switch"]             = "keyword",
    ["synchronizedthis"]   = "keyword",
    ["threadsafe"]         = "keyword",
    ["throw"]              = "keyword",
    ["throws"]             = "keyword",
    ["transient"]          = "keyword",
    ["try"]                = "keyword",
    ["while"]              = "keyword",
    
    -- Contextual keywords
    ["as"]                 = "keyword",
    ["in"]                 = "keyword",
    ["permitsrecord"]      = "keyword",
    ["sealed"]             = "keyword",
    ["trait"]              = "keyword",
    ["var"]                = "keyword",
    ["yields"]             = "keyword",
    
    -- ?
    ["true"]               = "literal",
    ["false"]              = "literal",
    ["null"]               = "literal",
    ["boolean"]            = "literal",

    -- Types
    ["char"]               = "keyword",
    ["byte"]               = "keyword",
    ["short"]              = "keyword",
    ["int"]                = "keyword",
    ["long"]               = "keyword",
    ["float"]              = "keyword",
    ["double"]             = "keyword",
    
    ["Integer"]            = "keyword",
    ["BigInteger"]         = "keyword",
    ["Long"]               = "keyword",
    ["Float"]              = "keyword",
    ["BigDecimal"]         = "keyword",
    ["Double"]             = "keyword",
    ["String"]             = "keyword",
  },
}
