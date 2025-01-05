-- Author: Rohan Vashisht https://github.com/RohanVashisht1234

-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
    name = "Bend",
    files = { "%.bend$" },
    comment = "#",
    patterns = {
        { pattern = "#.*",                        type = "comment" },
        { pattern = { '"', '"' },                 type = "string" },
        { pattern = { "'", "'" },                 type = "string" },
        { pattern = "[%a_][%w_]*%f[(]",           type = "function" },
        { pattern = "[%a_][%w_]*",                type = "symbol" },
        { pattern = "[%+%-=/%*%^%%<>!|&]",        type = "operator" },
        { pattern = "def()%s+()[%a_][%w_]*",      type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "data()%s+()[%a_][%w_]*",     type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "let()%s+()[%a_][%w_]*",      type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "Some()%s+()[%a_][%w_]*",     type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "bend()%s+()[%a_][%w_]*",     type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "object()%s+()[%a_][%w_]*",   type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "fold()%s+()[%a_][%w_]*",     type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "open()%s+()[%a_][%w_]*",     type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "do()%s+()[%a_][%w_]*",       type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "identity()%s+()[%a_][%w_]*", type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "lambda()%s+()[%a_][%w_]*",   type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "0x[%da-fA-F]+",              type = "number" },
        { pattern = "-?%d+[%d%.eE]*",             type = "number" },
        { pattern = "-?%.?%d+",                   type = "number" },
    },
    symbols = {
        ["def"]        = "keyword",
        ["switch"]     = "keyword",
        ["case"]       = "keyword",
        ["return"]     = "keyword",
        ["if"]         = "keyword",
        ["else"]       = "keyword",
        ["when"]       = "keyword",
        ["match"]      = "keyword",
        ["λ"]          = "keyword",
        ["Some"]       = "keyword",
        ["data"]       = "keyword",
        ["let"]        = "keyword",
        ["use"]        = "keyword",
        ["object"]     = "keyword",
        ["fold"]       = "keyword",
        ["open"]       = "keyword",
        ["do"]         = "keyword",
        ["bind"]       = "keyword",
        ["Name"]       = "keyword",
        ["identity"]   = "keyword",
        ["Bool"]       = "keyword",
        ["ask"]        = "keyword",
        ["with"]       = "keyword",
        ["bend"]       = "keyword2",
        ["None"]       = "keyword2",
        ["Nil"]        = "keyword2",
        ["Result"]     = "keyword2",
        ["type"]       = "keyword2",
        ["true"]       = "literal",
        ["false"]      = "literal",
    }
}
