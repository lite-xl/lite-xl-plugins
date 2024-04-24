-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "PLC Structured Text IEC 61131-3",
  files = { "%.stx?$", "%.iecst$" },
  comment = "//",
  block_comment = { "%(%*", "%*%)" },
  patterns = {
    { pattern = "//.*",                               type = "comment"  }, -- Single-line comment
    { pattern = { "%(%*", "%*%)" },                   type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                   type = "string"   }, -- String, quotation marks
    { pattern = { "'", "'", '\\' },                   type = "string"   }, -- String, apices
    { regex   = "\\w+\\s?(?=[(])",                    type = "function" }, -- Function
    { regex   = "^\\s*[A-Z]+_[A-Z]*\\s?\\;?\\s?",     type = "keyword"  }, -- keyword
    { regex   = "\\:\\s?[A-Z]+",                      type = "keyword2" }, -- Variable/Method type
    { pattern = "[%+%-=/%*%^%%<>!~|&:]",              type = "operator" }, -- Operators
    { pattern = "-?0x%x+",                            type = "number"   }, -- Number
    { pattern = "-?%d+[%deE]*f?",                     type = "number"   }, -- Number
    { pattern = "-?%.?%d+f?",                         type = "number"   }, -- Number
    { regex   = "T\\#[0-9]+m?s",                      type = "number"   }, -- Time format
    -- TODO: function name in definition
    -- TODO: function name in call
  },
  symbols = {
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
    
    ["IF"] = "keyword",
    ["THEN"] = "keyword",
    ["ELSE"] = "keyword",
    ["ELSIF"] = "keyword",
    ["END_IF"] = "keyword",
    ["CASE"] = "keyword",
    ["END_CASE"] = "keyword",
    ["OF"] = "keyword",
    
    ["AND"] = "keyword",
    ["NOT"] = "keyword",
    
    ["NAMESPACE"] = "keyword",
    ["END_NAMESPACE"] = "keyword",
    
    ["VAR"] = "keyword",
    ["END_VAR"] = "keyword",
    ["CONST"] = "keyword",
    ["END_CONST"] = "keyword",
    
    ["TYPE"] = "keyword",
    ["END_TYPE"] = "keyword",
    
    ["ORGANIZATION_BLOCK"] = "keyword",
    ["END_ORGANIZATION_BLOCK"] = "keyword",
    
    ["TRUE"] = "literal",
    ["FALSE"] = "literal",
    ["true"] = "literal",
    ["false"] = "literal",

    ["bool"] = "keyword2",
    ["sint"] = "keyword2",
    ["int"] = "keyword2",
    ["dint"] = "keyword2",
    ["lint"] = "keyword2",
    ["usint"] = "keyword2",
    ["uint"] = "keyword2",
    ["ldint"] = "keyword2",
    ["ulint"] = "keyword2",
    ["real"] = "keyword2",
    ["lreal"] = "keyword2",
    ["time"] = "keyword2",
    ["date"] = "keyword2",
    ["time_of_day"] = "keyword2",
    ["date_and_time"] = "keyword2",
    ["string"] = "keyword2",
    ["bool"] = "keyword2",
    ["byte"] = "keyword2",
    ["word"] = "keyword2",
    ["dword"] = "keyword2",
    ["lword"] = "keyword2",
  }
}
