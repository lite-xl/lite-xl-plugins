-- mod-version:2 -- lite-xl 2.0

-- Syntax highlighting for the Rivet programming language.
-- by StunxFS :)

local syntax = require "core.syntax"

syntax.add {
    name = "Rivet",
    files = {"%.ri$"},
    comment = "//",
    block_comment = {"/*", "*/"},
    patterns = {
        {pattern = "//.*", type = "comment"},
        {pattern = {"/%*", "%*/"}, type = "comment"},
        {pattern = {'[bcr]?"', '"', "\\"}, type = "string"},
        {pattern = {"[b]?'", "'", "\\"}, type = "string"},
        {pattern = "0b[01_]+", type = "number"},
        {pattern = "0o[0-7_]+", type = "number"},
        {pattern = "0x[%x_]+", type = "number"},
        {pattern = "%d[%d_]*%.[%d_]*[eE][-+]?%d+", type = "number"},
        {pattern = "%d[%d_]*%.[%d_]*", type = "number"},
        {pattern = "%d[%d_]*", type = "number"},
        {pattern = "-?%.?%d+", type = "number"},
        {pattern = "[%+%-=/%*%^%%<>!~|&%.%?:;]", type = "operator"},
        {
            pattern = "[%a_][%w_]*()%s*()::",
            type = {"keyword2", "normal", "keyword2"}
        },
        {
            pattern = "_?%u[%u_][%u%d_]*%f[%s%+%*%-%.%)%]}%?%^%%=/<>~|&;:,!]",
            type = "number"
        },
        {pattern = "pkg%s()[%a_][%w_]*", type = {"keyword", "keyword2"}},
        {pattern = "mod%s()[%a_][%w_]*", type = {"keyword", "keyword2"}},
        {
            pattern = "use%s()[%a_][%w_]*::[%a_][%w_]*()",
            type = {"keyword", "keyword2", "keyword2"}
        },
        {pattern = "[A-Z][%w_]*", type = "keyword2"}, -- types
        {pattern = "[%a_][%w_]*%f[(]", type = "function"},
        {pattern = "[%a_][%w_]*!%f[(]", type = "keyword2"}, -- builtin-fn
        {pattern = "[%a_][%w_]*", type = "symbol"},
        {pattern = {"#%[", "%]"}, type = "literal"},
        {pattern = "#%s?[%a_][%w_]*", type = "comment"}
    },
    symbols = {
        ["and"] = "keyword",
        ["as"] = "keyword",
        ["base"] = "literal",
        ["break"] = "keyword",
        ["catch"] = "keyword",
        ["class"] = "keyword",
        ["const"] = "keyword",
        ["continue"] = "keyword",
        ["defer"] = "keyword",
        ["else"] = "keyword",
        ["enum"] = "keyword",
        ["extend"] = "keyword",
        ["extern"] = "keyword",
        ["false"] = "literal",
        ["fn"] = "keyword",
        ["for"] = "keyword",
        ["if"] = "keyword",
        ["in"] = "keyword",
        ["is"] = "keyword",
        ["let"] = "keyword",
        ["mod"] = "keyword",
        ["mut"] = "keyword",
        ["none"] = "literal",
        ["or"] = "keyword",
        ["pkg"] = "keyword",
        ["pub"] = "keyword",
        ["prot"] = "keyword",
        ["return"] = "keyword",
        ["self"] = "literal",
        ["struct"] = "keyword",
        ["switch"] = "keyword",
        ["test"] = "keyword",
        ["trait"] = "keyword",
        ["true"] = "literal",
        ["type"] = "keyword",
        ["unsafe"] = "keyword",
        ["use"] = "keyword",
        ["while"] = "keyword",

        -- types
        ["never"] = "keyword2",
        ["void"] = "keyword2",
        ["bool"] = "keyword2",
        ["i8"] = "keyword2",
        ["i16"] = "keyword2",
        ["i32"] = "keyword2",
        ["i64"] = "keyword2",
        ["isize"] = "keyword2",
        ["u8"] = "keyword2",
        ["u16"] = "keyword2",
        ["u32"] = "keyword2",
        ["u64"] = "keyword2",
        ["usize"] = "keyword2",
        ["f32"] = "keyword2",
        ["f64"] = "keyword2",
        ["rune"] = "keyword2",
        ["string"] = "keyword2",
        ["Base"] = "keyword2",
        ["Self"] = "keyword2"
    }
}
