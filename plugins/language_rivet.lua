-- mod-version:3

-- Syntax highlighting for the Rivet programming language.
-- This plugin is always updated to the latest Rivet syntax.
-- By StunxFS =).

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
        {pattern = "[%[%]%(%)%+%-=/%*%^%%<>!~|&%.%?:;]", type = "operator"},
        {
            pattern = "_?%u[%u_][%u%d_]*%f[%s%+%*%-%.%)%]}%?%^%%=/<>~|&;:,!]",
            type = "literal"
        },
        {pattern = "[A-Z][%w_]*", type = "keyword2"}, -- types
        {pattern = "%@%s?[%a_][%w_]*", type = "literal"}, -- builtin func/var
        {pattern = "[%a_][%w_]*%f[(]", type = "function"},
        {pattern = "#%s?[%a_][%w_]*", type = "comment"}, -- if/else_if/else/endif
        {pattern = "#%s?.*", type = "keyword2"}, -- attributes
        {pattern = "[%a_][%w_]*", type = "symbol"}
    },
    symbols = {
        ["alias"] = "keyword",
        ["and"] = "keyword",
        ["as"] = "keyword",
        ["break"] = "keyword",
        ["catch"] = "keyword",
        ["comptime"] = "keyword",
        ["const"] = "keyword",
        ["continue"] = "keyword",
        ["defer"] = "keyword",
        ["else"] = "keyword",
        ["enum"] = "keyword",
        ["errdefer"] = "keyword",
        ["extend"] = "keyword",
        ["extern"] = "keyword",
        ["func"] = "keyword",
        ["for"] = "keyword",
        ["from"] = "keyword",
        ["if"] = "keyword",
        ["import"] = "keyword",
        ["in"] = "keyword",
        ["is"] = "keyword",
        ["mut"] = "keyword",
        ["or"] = "keyword",
        ["public"] = "keyword",
        ["return"] = "keyword",
        ["static"] = "keyword",
        ["struct"] = "keyword",
        ["switch"] = "keyword",
        ["test"] = "keyword",
        ["throw"] = "keyword",
        ["trait"] = "keyword",
        ["unsafe"] = "keyword",
        ["while"] = "keyword",

        -- literals
        ["false"] = "literal",
        ["none"] = "literal",
        ["self"] = "literal",
        ["true"] = "literal",
        ["undefined"] = "literal",

        -- types
        ["never"] = "keyword2",
        ["bool"] = "keyword2",
        ["comptime_int"] = "keyword2",
        ["comptime_float"] = "keyword2",
        ["int8"] = "keyword2",
        ["int16"] = "keyword2",
        ["int32"] = "keyword2",
        ["int64"] = "keyword2",
        ["isize"] = "keyword2",
        ["uint8"] = "keyword2",
        ["uint16"] = "keyword2",
        ["uint32"] = "keyword2",
        ["uint64"] = "keyword2",
        ["usize"] = "keyword2",
        ["float32"] = "keyword2",
        ["float64"] = "keyword2",
        ["rawptr"] = "keyword2",
        ["rune"] = "keyword2",
        ["string"] = "keyword2",
        ["Self"] = "keyword2"
    }
}
