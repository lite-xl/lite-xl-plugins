-- Author: Rohan Vashisht: https://github.com/rohanvashisht1234/

-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
    name = "Carbon",                                                                           -- tested ok
    files = {
        "%.carbon$"                                                                            -- tested ok
    },
    comment = "//",                                                                            -- tested ok
    patterns = {
        { pattern = { '"', '"', '\\' },           type = "string" },                           -- tested ok
        { pattern = { '"""', '"""', '\\' },       type = "string" },                           -- tested ok
        { pattern = { "'''", "'''", '\\' },       type = "string" },                           -- tested ok
        { pattern = "//.*",                       type = "comment" },                          -- tested ok
        { pattern = "[!%-/*?:=><+]",              type = "operator" },                         -- tested ok
        { pattern = "[%a_][%w_]*%f[(]",           type = "function" },                         -- tested ok
        { pattern = "packages()%s+()[%a_][%w_]*", type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "let()%s+()[%a_][%w_]*",      type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "import()%s+()[%a_][%w_]*",   type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "impl()%s+()[%a_][%w_]*",     type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "class()%s+()[%a_][%w_]*",    type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "var()%s+()[%a_][%w_]*",      type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "package()%s+()[%a_][%w_]*",  type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "-?%d+[%d%.eE_]*",            type = "number" },                           -- tested ok
        { pattern = "-?%.?%d+",                   type = "number" },                           -- tested ok
        { pattern = "[%a_][%w_]*",                type = "normal" },                           -- tested ok
    },
    symbols = {
        ["package"]  = "keyword",  -- tested ok
        ["import"]   = "keyword",  -- tested ok
        ["fn"]       = "keyword",  -- tested ok
        ["var"]      = "keyword",  -- tested ok
        ["for"]      = "keyword",  -- tested ok
        ["return"]   = "keyword",  -- tested ok
        ["class"]    = "keyword",  -- tested ok
        ["api"]      = "keyword",  -- tested ok
        ["i8"]       = "keyword",  -- tested ok
        ["i16"]      = "keyword",  -- tested ok
        ["i32"]      = "keyword",  -- tested ok
        ["i64"]      = "keyword",  -- tested ok
        ["i128"]     = "keyword",  -- tested ok
        ["i256"]     = "keyword",  -- tested ok
        ["u8"]       = "keyword",  -- tested ok
        ["u16"]      = "keyword",  -- tested ok
        ["u32"]      = "keyword",  -- tested ok
        ["u64"]      = "keyword",  -- tested ok
        ["u128"]     = "keyword",  -- tested ok
        ["u256"]     = "keyword",  -- tested ok
        ["f8"]       = "keyword",  -- tested ok
        ["f16"]      = "keyword",  -- tested ok
        ["f32"]      = "keyword",  -- tested ok
        ["f64"]      = "keyword",  -- tested ok
        ["f128"]     = "keyword",  -- tested ok
        ["if"]       = "keyword",  -- tested ok
        ["else"]     = "keyword",  -- tested ok
        ["auto"]     = "keyword",  -- tested ok
        ["let"]      = "keyword",  -- tested ok
        ["File"]     = "keyword",  -- tested ok
        ["while"]    = "keyword",  -- tested ok
        ["match"]    = "keyword",  -- tested ok
        ["case"]     = "keyword",  -- tested ok
        ["default"]  = "keyword",  -- tested ok
        ["returned"] = "keyword",  -- tested ok
        ["base"]     = "keyword",  -- tested ok
        ["bool"]     = "keyword",  -- tested ok
        ["virtual"]  = "keyword",  -- tested ok
        ["abstract"] = "keyword",  -- tested ok
        ["String"]   = "keyword",  -- tested ok

        ["impl"]     = "keyword2", -- tested ok
        ["extend"]   = "keyword",  -- tested ok
        ["partial"]  = "keyword2", -- tested ok
        ["Self"]     = "keyword",  -- tested ok
        ["Int"]      = "keyword",  -- tested ok
        ["UInt"]     = "keyword",  -- tested ok
        ["Base"]     = "keyword",  -- tested ok
        ["template"] = "keyword2", -- tested ok
        ["true"]     = "keyword2", -- tested ok
        ["false"]    = "keyword2", -- tested ok
    }
}
