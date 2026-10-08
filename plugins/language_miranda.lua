--priority:101
-- Author: moooodie: https://github.com/moooodie/

-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
    name = "Miranda",
    files = { "%.m$" },
    comment = "||",

    patterns = {
        -- comments
        { pattern =  "||.*\n", type = "comment" },

        -- strings
        { pattern = {'"', '"', '\\'}, type = "string" },
        { pattern = {"'", "'", '\\'}, type = "string" },

        -- number literals (-?\d+(e-?\d+)?)
        { pattern = "-?0x%x+", type = "number" },
        { regex = [[-?\d+(?:e-?\d+)?]], type = "number" },
        { regex = [[-?\d+\.\d+(?:e-?\d+)?]], type = "number" },

        --operators
        { pattern = "%-%>", type = "operator" },
        { pattern = "::", type = "operator" },
        { pattern = "\\/", type = "operator" },
        { pattern = "[!#%.%^>=~<&:%-%+%*/]", type = "operator" },
        { pattern = "%$%w+", type = "operator" },

        -- identifiers (specifically variable and typenames)
        { pattern = "%l[%w_']*", type = "symbol" },

        -- identifiers (specifically type constructors)
        { pattern = "%u[%w_']*", type = "literal" },

        -- compiler directives
        { pattern = "%%%w+", type = "symbol" },
    },

    symbols = {
        -- reserved words 
        ["abstype"]     = "keyword",
        ["div"]         = "keyword",
        ["if"]          = "keyword",
        ["mod"]         = "keyword",
        ["otherwise"]   = "keyword",
        ["readvals"]    = "keyword",
        ["show"]        = "keyword",
        ["type"]        = "keyword",
        ["where"]       = "keyword",
        ["with"]        = "keyword",

        -- compiler directives
        ["%include"]    = "keyword",
        ["%export"]     = "keyword",
        ["%free"]       = "keyword",
        ["%insert"]     = "keyword",
        ["%list"]       = "keyword",
        ["%nolist"]     = "keyword",


        -- builtin types
        ["bool"]        = "keyword2",
        ["char"]        = "keyword2",
        ["num"]         = "keyword2",
        ["sys_message"] = "keyword2",

        -- predefined variables/functions
        ["e"]           = "keyword",
        ["hugenum"]     = "keyword",
        ["pi"]          = "keyword",
        ["tinynum"]     = "keyword",
        ["undef"]       = "keyword",
        
        ["abs"]         = "function",
        ["and"]         = "function",
        ["arctan"]      = "function",
        ["cjustify"]    = "function",
        ["code"]        = "function",
        ["concat"]      = "function",
        ["const"]       = "function",
        ["converse"]    = "function",
        ["cos"]         = "function",
        ["decode"]      = "function",
        ["digit"]       = "function",
        ["drop"]        = "function",
        ["dropwhile"]   = "function",
        ["entier"]      = "function",
        ["error"]       = "function",
        ["exp"]         = "function",
        ["filemode"]    = "function",
        ["filter"]      = "function",
        ["foldl"]       = "function",
        ["foldl1"]      = "function",
        ["foldr"]       = "function",
        ["foldr1"]      = "function",
        ["force"]       = "function",
        ["fst"]         = "function",
        ["getenv"]      = "function",
        ["hd"]          = "function",
        ["id"]          = "function",
        ["index"]       = "function",
        ["init"]        = "function",
        ["integer"]     = "function",
        ["iterate"]     = "function",
        ["last"]        = "function",
        ["lay"]         = "function",
        ["layn"]        = "function",
        ["letter"]      = "function",
        ["limit"]       = "function",
        ["lines"]       = "function",
        ["ljustify"]    = "function",
        ["log"]         = "function",
        ["log10"]       = "function",
        ["map"]         = "function",
        ["map2"]        = "function",
        ["max"]         = "function",
        ["max2"]        = "function",
        ["member"]      = "function",
        ["merge"]       = "function",
        ["min"]         = "function",
        ["min2"]        = "function",
        ["mkset"]       = "function",
        ["neg"]         = "function",
        ["numval"]      = "function",
        ["or"]          = "function",
        ["postfix"]     = "function",
        ["product"]     = "function",
        ["read"]        = "function",
        ["rep"]         = "function",
        ["repeat"]      = "function",
        ["reverse"]     = "function",
        ["rjustify"]    = "function",
        ["scan"]        = "function",
        ["seq"]         = "function",
        ["showfloat"]   = "function",
        ["shownum"]     = "function",
        ["showscaled"]  = "function",
        ["sin"]         = "function",
        ["snd"]         = "function",
        ["sort"]        = "function",
        ["spaces"]      = "function",
        ["sqrt"]        = "function",
        ["subtract"]    = "function",
        ["sum"]         = "function",
        ["system"]      = "function",
        ["take"]        = "function",
        ["takewhile"]   = "function",
        ["tl"]          = "function",
        ["transpose"]   = "function",
        ["until"]       = "function",
        ["zip2"]        = "function",
        ["zip3"]        = "function",
        ["zip4"]        = "function",
        ["zip5"]        = "function",
        ["zip6"]        = "function",
        ["zip"]         = "function",
    }
}
