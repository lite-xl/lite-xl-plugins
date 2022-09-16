-- mod-version:3

-- Syntax highlighting for the Rivet programming language.
-- by StunxFS :)

local syntax = require "core.syntax"

syntax.add {
  name = "Rivet",
  files = {"%.ri$"},
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {
    {pattern = "//.-\n", type = "comment"},
    {pattern = {"/%*", "%*/"}, type = "comment"},
    {pattern = {'[bcr]?"', '"', "\\"}, type = "string"},
    {pattern = {"[b]?'", "'", '\\' }, type = "string"},
    {pattern = "0b[01_]+", type = "number"},
    {pattern = "0o[0-7_]+", type = "number"},
    {pattern = "0x[%x_]+", type = "number"},
    {pattern = "%d[%d_]*%.[%d_]*[eE][-+]?%d+", type = "number"},
    {pattern = "%d[%d_]*%.[%d_]*", type = "number"},
    {pattern = "%d[%d_]*", type = "number"},
    {pattern = "-?%.?%d+", type = "number"},
    {pattern = "[%+%-=/%*%^%%<>!~|&%.%?]", type = "operator"},
    -- Uppercase constants of at least 2 chars in length
    {
      pattern = "_?%u[%u_][%u%d_]*%f[%s%+%*%-%.%)%]}%?%^%%=/<>~|&;:,!]",
      type = "number"
    },
    {pattern = "[A-Z][%w_]*", type = "keyword2"}, -- types
    {pattern = "[%a_][%w_]*%f[(]", type = "function"},
    {pattern = "[%a_][%w_]*!%f[(]", type = "keyword2"},
    {pattern = "[%a_][%w_]*", type = "symbol"},
    {pattern = {"#%[", "%]"}, type = "keyword"},
    {pattern = "%$%s?[%a_][%w_]*", type = "keyword2"},
  },
  symbols = {
    ["pub"] = "keyword",

    ["extern"] = "keyword",
    ["using"] = "keyword",
    ["pkg"] = "keyword",
    ["mod"] = "keyword",
    ["const"] = "keyword",
    ["trait"] = "keyword",
    ["union"] = "keyword",
    ["class"] = "keyword",
    ["struct"] = "keyword",
    ["enum"] = "keyword",
    ["errtype"] = "keyword",
    ["type"] = "keyword",
    ["extend"] = "keyword",
    ["test"] = "keyword",
    ["fn"] = "keyword",

    -- comptime `if` stmt/expr
    ["$if"] = "keyword",
    ["$else"] = "keyword",

    ["if"] = "keyword",
    ["else"] = "keyword",
    ["switch"] = "keyword",
    ["while"] = "keyword",
    ["for"] = "keyword",

    ["break"] = "keyword",
    ["continue"] = "keyword",
    ["return"] = "keyword",
    ["raise"] = "keyword",

    ["unsafe"] = "keyword",
    ["defer"] = "keyword",
    ["var"] = "keyword",
    ["mut"] = "keyword",
    ["and"] = "keyword",
    ["or"] = "keyword",
    ["orelse"] = "keyword",
    ["catch"] = "keyword",
    ["is"] = "keyword",
    ["in"] = "keyword",
    ["as"] = "keyword",

    -- types
    ["no_return"] = "keyword2",
    ["bool"] = "keyword2",
    ["i8"] = "keyword2",
    ["i16"] = "keyword2",
    ["i32"] = "keyword2",
    ["i64"] = "keyword2",
    ["u8"] = "keyword2",
    ["u16"] = "keyword2",
    ["u32"] = "keyword2",
    ["u64"] = "keyword2",
    ["isize"] = "keyword2",
    ["usize"] = "keyword2",
    ["f32"] = "keyword2",
    ["f64"] = "keyword2",
    ["rune"] = "keyword2",
    ["string"] = "keyword2",
    ["Self"] = "keyword2",

    -- literals
    ["super"] = "literal",
    ["self"] = "literal",
    ["true"] = "literal",
    ["false"] = "literal",
    ["none"] = "literal"
  }
}
