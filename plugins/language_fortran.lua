-- Author: Rohan Vashisht: https://github.com/rohanvashisht1234/


-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
    name = "Fortran",                                                                         -- tested ok
    files = {
        "%.f$",                                                                               -- tested ok
        "%.f90$",                                                                             -- tested ok
        "%.f95$"                                                                              -- tested ok
    },
    comment = "!",                                                                            -- tested ok
    patterns = {
        { pattern = { "'", "'", '\\' },          type = "string" },                           -- tested ok
        { pattern = { '"', '"', '\\' },          type = "string" },                           -- tested ok
        { pattern = "!.*",                       type = "comment" },                          -- tested ok
        { pattern = "%.[%a_][%w_]+%.",           type = "normal" },                           -- tested ok
        { pattern = "[!%-/*?:=><+]",             type = "operator" },                         -- tested ok
        { pattern = "[%a_][%w_]*%f[(]",          type = "function" },                         -- tested ok
        { pattern = "program()%s+()[%a_][%w_]*", type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "module()%s+()[%a_][%w_]*",  type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "use()%s+()[%a_][%w_]*",     type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "struct()%s+()[%a_][%w_]*",  type = { "keyword", "normal", "literal" } }, -- tested ok

        { pattern = "-?%d+[%d%.eE_]*",           type = "number" },                           -- tested ok
        { pattern = "-?%.?%d+",                  type = "number" },                           -- tested ok
        { pattern = "[%a_][%w_]*",               type = "normal" },                           -- tested ok
    },
    symbols = {
        ["end"]         = "keyword", -- tested ok
        ["program"]     = "keyword", -- tested ok
        ["write"]       = "keyword", -- tested ok
        ["print"]       = "keyword", -- tested ok
        ["implicit"]    = "keyword", -- tested ok
        ["integer"]     = "keyword", -- tested ok
        ["real"]        = "keyword", -- tested ok
        ["complex"]     = "keyword", -- tested ok
        ["character"]   = "keyword", -- tested ok
        ["logical"]     = "keyword", -- tested ok
        ["allocatable"] = "keyword", -- tested ok
        ["subroutine"]  = "keyword", -- tested ok
        ["do"]          = "keyword", -- tested ok
        ["call"]        = "keyword", -- tested ok
        ["extends"]     = "keyword", -- tested ok
        ["protected"]   = "keyword", -- tested ok
        ["contains"]    = "keyword", -- tested ok
        ["else"]        = "keyword", -- tested ok
        ["then"]        = "keyword", -- tested ok
        ["if"]          = "keyword", -- tested ok
        ["cycle"]       = "keyword", -- tested ok
        ["parameter"]   = "keyword", -- tested ok
        ["concurrent"]  = "keyword", -- tested ok
        ["function"]    = "keyword", -- tested ok
        ["private"]     = "keyword", -- tested ok
        ["public"]      = "keyword", -- tested ok
        ["module"]      = "keyword", -- tested ok
        ["use"]         = "keyword", -- tested ok
        ["type"]        = "keyword", -- tested ok
        ["sequence"]    = "keyword", -- tested ok
        ["struct"]      = "keyword", -- tested ok
        ["result"]      = "keyword", -- tested ok
        ["stop"]        = "keyword", -- tested ok
        ["only"]        = "keyword", -- tested ok


        ["none"]    = "keyword2", -- tested ok
        ["len"]     = "keyword2", -- tested ok

        [".false."] = "keyword2", -- tested ok
        [".true."]  = "keyword2", -- tested ok
        [".eq."]    = "keyword2", -- tested ok
        [".ne."]    = "keyword2", -- tested ok
        [".gt."]    = "keyword2", -- tested ok
        [".lt."]    = "keyword2", -- tested ok
        [".ge"]     = "keyword2", -- tested ok
        [".not."]   = "keyword2", -- tested ok
        [".le."]    = "keyword2", -- tested ok
        [".or."]    = "keyword2", -- tested ok
        [".and."]   = "keyword2", -- tested ok
        [".eqv."]   = "keyword2", -- tested ok
        [".neqv."]  = "keyword2", -- tested ok
    }
}
