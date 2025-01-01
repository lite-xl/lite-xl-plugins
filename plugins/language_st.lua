-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax References
-- https://pdhonline.com/courses/e334/e334content.pdf

syntax.add {
  name = "PLC Structured Text IEC 61131-3",
  files = { "%.stx?$", "%.iecst$" },
  comment = "//",
  block_comment = { "%(%*", "%*%)" },
  patterns = {
    { pattern = "//.*",                                     type = "comment"  }, -- Single-line comment
    { pattern = { "%(%*", "%*%)" },                         type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                         type = "string"   }, -- String, quotation marks
    { pattern = { "'", "'", '\\' },                         type = "string"   }, -- String, apices
    { pattern = "%w+#[0-9]+m?s?",                           type = "number"   }, -- Time/Date formats
    { pattern = "[%a_][%w_]*%f[(]",                         type = "function" }, -- Function
    { pattern = "[%a_][%w_]*",                              type = "symbol"   }, -- Symbols
    { pattern = ":%s*%w[%w_]*",                             type = "keyword2" }, -- Variable/Method Type
    { regex   = [[[-+]?\d+\.{2,4}[-+]?\d+]],                type = "number"   }, -- Number Range
    { pattern = "[%+%-=/%*%^%%<>!~|&:]",                    type = "operator" }, -- Operators
    { pattern = "-?0x%x+",                                  type = "number"   }, -- Number
    { pattern = "-?%d+[%deE]*f?",                           type = "number"   }, -- Number
    { pattern = "-?%.?%d+f?",                               type = "number"   }, -- Number
  },
  symbols = {
    ["PROGRAM"] = "keyword",
    ["PROGRAM_INIT"] = "keyword",
    ["PROGRAM_CYCLIC"] = "keyword",
    
    ["PROGRAM_CLOSE"] = "keyword",
    ["END_PROGRAM"] = "keyword",
    ["FUNCTION_BLOCK"] = "keyword",
    ["END_FUNCTION_BLOCK"] = "keyword",
    ["FUNCTION"] = "keyword",
    ["END_FUNCTION"] = "keyword",
    ["METHOD"] = "keyword",
    ["END_METHOD"] = "keyword",
    ["IMPLEMENTATION"] = "keyword",
    ["END_IMPLEMENTATION"] = "keyword",
    ["INTERFACE"] = "keyword",
    ["END_INTERFACE"] = "keyword",
    
    ["IF"] = "keyword",
    ["THEN"] = "keyword",
    ["ELSE"] = "keyword",
    ["ELSIF"] = "keyword",
    ["END_IF"] = "keyword",
    ["CASE"] = "keyword",
    ["END_CASE"] = "keyword",
    ["OF"] = "keyword",
    ["FOR"] = "keyword",
    ["TO"] = "keyword",
    ["BY"] = "keyword",
    ["DO"] = "keyword",
    ["END_FOR"] = "keyword",
    ["WHILE"] = "keyword",
    ["END_WHILE"] = "keyword",
    ["REPEAT"] = "keyword",
    ["END_REPEAT"] = "keyword",

    ["MOD"] = "operator",
    ["UNTIL"] = "operator",
    ["EXIT"] = "keyword",
    ["RETURN"] = "keyword",
    
    ["AND"] = "keyword",
    ["NOT"] = "keyword",
    ["OR"] = "keyword",
    ["XOR"] = "keyword",
    
    ["NAMESPACE"] = "keyword",
    ["END_NAMESPACE"] = "keyword",
    
    ["VAR"] = "keyword",
    ["VAR_GLOBAL"] = "keyword",
    ["VAR_INPUT"] = "keyword",
    ["VAR_OUTPUT"] = "keyword",
    ["VAR_IN_OUT"] = "keyword",
    ["VAR_ACCESS"] = "keyword",
    ["VAR_EXTERNAL"] = "keyword",
    ["VAR_TEMP"] = "keyword",
    ["AT"] = "keyword",
    ["RETAIN"] = "keyword",
    ["END_VAR"] = "keyword",
    ["CONST"] = "keyword",
    ["END_CONST"] = "keyword",
    
    ["TYPE"] = "keyword",
    ["END_TYPE"] = "keyword",
    ["STRUCT"] = "keyword",
    ["END_STRUCT"] = "keyword",
    
    ["ORGANIZATION_BLOCK"] = "keyword",
    ["END_ORGANIZATION_BLOCK"] = "keyword",
    
    ["TRUE"] = "literal",
    ["FALSE"] = "literal",
    ["true"] = "literal",
    ["false"] = "literal",
    
    ["SINT"] = "keyword2",
    ["INT"] = "keyword2",
    ["DINT"] = "keyword2",
    ["LINT"] = "keyword2",
    ["USINT"] = "keyword2",
    ["UINT"] = "keyword2",
    ["UDINT"] = "keyword2",
    ["ULINT"] = "keyword2",
    ["LDINT"] = "keyword2",
    ["REAL"] = "keyword2",
    ["LREAL"] = "keyword2",
    ["TIME"] = "keyword2",
    ["DATE"] = "keyword2",
    ["TIME_OF_DAY"] = "keyword2",
    ["DATE_AND_TIME"] = "keyword2",
    ["STRING"] = "keyword2",
    ["BOOL"] = "keyword2",
    ["BYTE"] = "keyword2",
    ["WORD"] = "keyword2",
    ["DWORD"] = "keyword2",
    ["LWORD"] = "keyword2",
  }
}
