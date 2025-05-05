-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax References
-- https://docs.oracle.com/javase/specs/jls/se8/html/index.html

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
    { pattern = "-?0x%x+",                                    type = "number"   }, -- Number, hexadecimal
    { pattern = "-?%d+[%d%.eE]*f?",                           type = "number"   }, -- Number, exponential
    { pattern = "-?%.?%d+f?",                                 type = "number"   }, -- Number
    { pattern = "[%+%-=/%*%^%%<>!~|&]",                       type = "operator" }, -- Operator
    { pattern = "[%a_][%w_]*%f[(]",                           type = "function" }, -- Method
    { pattern = "^import()%s+()[%w_.]+",                      type = { "keyword", "normal", "normal" } }, -- Import
    -- Class name reference, ;
    { pattern = "^%s*()return()%s*%.-()%;$",                  type = { "normal", "keyword", "symbol", "normal" } }, -- Fix class name reference, ; pattern
    { pattern = "^%w+%s*()%w+%s*%;",                          type = { "function", "normal" } },
    { pattern = "^%w+%s*()%<.-%>()%s*%w+%s*%;",               type = { "function", "keyword2", "normal" } },
    -- FIX: valid only when preceded by a single keyword (es. private), when using more than one (es. private static) it breaks
    { pattern = "^%s*%w+%s*()%w+()%<.-%>()%s*%w+%s*%;",       type = { "keyword", "function", "keyword2", "normal" } },
    { pattern = "^%s*%w+%s*()%w+%s*()%w+%s*%;",               type = { "keyword", "function", "normal" } },
    -- Class name reference, =
    -- FIX: paramClassDiagramTextToWrap = builder.toString();
    -- FIX: return paramClassDiagramTextToWrap;
    -- FIX: classDiagramText = createAsciidocWrappedDiagramText(classDiagramText);
    -- FIX: IOUtils.write(classDiagramText, outputStream, getEncoding());
    -- FIX: this.outputFilename = outputFilename;
    -- FIX: if (whitelistRegexp == null || "".equals(whitelistRegexp)) {
    { pattern = "%w+%s*()%w+%s*()%=",                         type = { "function", "normal", "operator" } },
    { pattern = "%w+%s*()%<.-%>()%s*%w+%s*()%=",              type = { "function", "keyword2", "normal", "operator" } },
    -- Class name reference, new
    { pattern = "new()%s*%w+()%<.-%>()%f[(]",                 type = { "keyword", "function", "keyword2", "normal" } },
    { pattern = "new()%s*%w+()%f[(]",                         type = { "keyword", "function", "normal" } },
    -- Class name reference, ( then ,
    { pattern = "%(%s*()%w+%s*()%w+%s*%,",                    type = { "normal", "function", "normal" } },
    { pattern = "%(%s*()%w+()%<.-%>()%s*%w+%s*%,",            type = { "normal", "function", "keyword2", "normal" } },
    -- Class name reference, (final then ,
    { pattern = "%(%s*()final%s*()%w+()%<.-%>()%s*%w+%s*%,",  type = { "normal", "keyword", "function", "keyword2", "normal" } },
    { pattern = "%(%s*()final%s*()%w+%s*()%w+%s*%,",          type = { "normal", "keyword", "function", "normal" } },
    -- Class name reference, , then ,
    { pattern = "%s*()%w+%s+()%w+%s*%,",                      type = { "normal", "function", "normal" } },
    { pattern = "%s*()%w+()%<.-%>()%s+%w+%s*%,",              type = { "normal", "function", "keyword2", "normal" } },
    -- Class name reference, , then )
    { pattern = "%s*()%w+()%s+%w+%s*%)",                      type = { "normal", "function", "normal" } },
    { pattern = "%s*()%w+()%<.-%>()%s+%w+%s*%)",              type = { "normal", "function", "keyword2", "normal" } },
    -- Class name reference, ( then )
    { pattern = "%(%s*()%w+%s*()%w+%s*%)",                    type = { "normal", "function", "normal" } },
    { pattern = "%(%s*()%w+()%<.-%>()%s*()%w+%s*%)",          type = { "normal", "function", "keyword2", "normal" } },
    -- Array
    { pattern = "%w+()%[()%d*()%]",                           type = { "function", "normal", "number", "normal" } },
    -- Class name reference, method
    { pattern = "%w+%s+()%w+%s*()%f[(]",                      type = { "keyword", "function", "normal" } },
    { pattern = "%w+()%<.-%>()%s+%w+%s*()%f[(]",              type = { "function", "keyword2", "function", "normal" } },
    -- Other patterns
    -- TODO: see if there are regex patterns that can be converted to lua patterns
    { regex   = [[this(?=\.?\@?)]],                           type = "keyword"  }, -- this keyword
    { pattern = "^%s*%@.+%)",                                 type = "keyword2" }, -- Annotation (at line start)
    { regex   = [[\s*\@.+\)(?=\s+\w+)]],                      type = "keyword2" }, -- Annotation (at line middle)
    { pattern = "%@%w+",                                      type = "keyword2" }, -- Annotation (like: final @Nullable String something;)
    { pattern = "[A-Z][A-Z_%d]+%f[^a-zA-Z_%d]",               type = "keyword2" }, -- Constants
    { pattern = "%:%:()%w+",                                  type = { "normal", "function" } }, -- Method reference with double colon operator
    { pattern = "%.class",                                    type = "normal"   }, -- .class should be colored as normal
    { pattern = "[%a_][%w_]*",                                type = "symbol"   }, -- Symbols
    -- WIP: check for missing syntaxes by opening an example Java project
    -- TODO: check if there are redundant/overlapping patterns
    -- TODO: private final VisibilityType maxVisibilityMethods = VisibilityType.PRIVATE;
    --       in this case VisibilityType should be colored as function
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
