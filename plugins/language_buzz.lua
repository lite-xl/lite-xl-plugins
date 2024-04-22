-- Author: Rohan Vashisht: https://github.com/rohanvashisht1234/


-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
    name = "Buzz",                                                                           -- tested ok
    files = { "%.buzz$" },                                                                   -- tested ok
    comment = "|",                                                                           -- tested ok
    patterns = {
        { pattern = { '"', '"', '\\' },         type = "string" },                           -- tested ok
        { pattern = "|.*",                      type = "comment" },                          -- tested ok
        { pattern = "[!%-/*?:=><]",             type = "operator" },                         -- tested ok
        { pattern = "[%a_][%w_]*%f[(]",         type = "function" },                         -- tested ok
        { pattern = "const()%s+()[%a_][%w_]*",  type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "object()%s+()[%a_][%w_]*", type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "var()%s+()[%a_][%w_]*",    type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "-?%d+[%d%.eE_]*",          type = "number" },                           -- tested ok
        { pattern = "-?%.?%d+",                 type = "number" },                           -- tested ok
        { pattern = "[%a_][%w_]*",              type = "normal" },                           -- tested ok
    },
    symbols = {
        ["bool"]      = "keyword",  -- tested ok
        ["ud"]        = "keyword",  -- tested ok
        ["float"]     = "keyword",  -- tested ok
        ["zdef"]      = "keyword",  -- tested ok
        ["resolve"]   = "keyword",  -- tested ok
        ["yield"]     = "keyword",  -- tested ok
        ["resume"]    = "keyword",  -- tested ok
        ["export"]    = "keyword",  -- tested ok
        ["void"]      = "keyword",  -- tested ok
        ["protocol"]  = "keyword",  -- tested ok
        ["do"]        = "keyword",  -- tested ok
        ["enum"]      = "keyword",  -- tested ok
        ["test"]      = "keyword",  -- tested ok
        ["extern"]    = "keyword",  -- tested ok
        ["object"]    = "keyword",  -- tested ok
        ["foreach"]   = "keyword",  -- tested ok
        ["is"]        = "keyword",  -- tested ok
        ["return"]    = "keyword",  -- tested ok
        ["continue"]  = "keyword",  -- tested ok
        ["for"]       = "keyword",  -- tested ok
        ["lambda"]    = "keyword",  -- tested ok
        ["try"]       = "keyword",  -- tested ok
        ["fun"]       = "keyword",  -- tested ok
        ["type"]      = "keyword",  -- tested ok
        ["while"]     = "keyword",  -- tested ok
        ["and"]       = "keyword",  -- tested ok
        ["global"]    = "keyword",  -- tested ok
        ["not"]       = "keyword2", -- tested ok
        ["any"]       = "keyword",  -- tested ok
        ["as"]        = "keyword",  -- tested ok
        ["if"]        = "keyword",  -- tested ok
        ["or"]        = "keyword",  -- tested ok
        ["else"]      = "keyword",  -- tested ok
        ["match"]     = "keyword",  -- tested ok
        ["pat"]       = "keyword",  -- tested ok
        ["import"]    = "keyword",  -- tested ok
        ["str"]       = "keyword",  -- tested ok
        ["var"]       = "keyword",  -- tested ok
        ["catch"]     = "keyword",  -- tested ok
        ["typeof"]    = "keyword",  -- tested ok
        ["int"]       = "keyword",  -- tested ok
        ["const"]     = "keyword",  -- tested ok
        ["namespace"] = "keyword",  -- tested ok
        ["this"]      = "keyword2", -- tested ok
        ["null"]      = "literal",  -- tested ok
        ["true"]      = "literal",  -- tested ok
        ["false"]     = "literal",  -- tested ok
        ["in"]        = "literal",  -- tested ok
        ["static"]    = "keyword2", -- tested ok
        ["std"]       = "keyword2", -- tested ok
        ["io"]        = "keyword2", -- tested ok
    }
}
