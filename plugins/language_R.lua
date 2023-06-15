-- mod-version:3
local syntax = require "core.syntax"

syntax.add{
  name = "R",
  files = {"%.r$", "%.rds$", "%.rda$", "%.rdata$", "%.R$"},
  comment = "#",
  patterns = {
    {pattern = {"#", "\n"}, type = "comment"},
    {pattern = {'"', '"'}, type = "string"},
    {pattern = {"'", "'"}, type = "string"},
    {pattern = "[%a_][%w_]*%f[(]", type = "function"},
    {pattern = "[%a_][%w_]*", type = "symbol"},
    {pattern = "[%+%-=/%*%^%%<>!|&]", type = "operator"},
    {pattern = "0x[%da-fA-F]+", type = "number"},
    {pattern = "-?%d+[%d%.eE]*", type = "number"},
    {pattern = "-?%.?%d+", type = "number"},
  },
  symbols = {
    ["TRUE"] = "literal",
    ["FALSE"] = "literal",
    ["NA"] = "literal",
    ["NULL"] = "literal",
    ["Inf"] = "literal",
    ["if"] = "keyword",
    ["else"] = "keyword",
    ["while"] = "keyword",
    ["function"] = "keyword",
    ["break"] = "keyword",
    ["next"] = "keyword",
    ["repeat"] = "keyword",
    ["in"] = "keyword",
    ["for"] = "keyword",
    ["NA_integer"] = "keyword",
    ["NA_complex"] = "keyword",
    ["NA_character"] = "keyword",
    ["NA_real"] = "keyword"
  }
}
