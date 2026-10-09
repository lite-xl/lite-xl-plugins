-- Author: moooodie: https://github.com/moooodie/


-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "F#",
  files = { "%.fs$", "%.fsi$", "%.fsx$" },
  comment = "//",
  block_comment = { "(*", "*)" },

  patterns = {
    -- comments
    { pattern = "//.*", type = "comment" },
    { pattern = { "%(%*", "%*%)" }, type = "comment" },

    -- attributes [<EntryPoint>]
    { pattern = { "%[%<", "%>%]" }, type = "keyword" },

    -- backtick identifiers ``identifier with spaces``
    { pattern = { "``", "``" }, type = "symbol" },

    -- strings
    { pattern = { '"', '"', '\\' }, type = "string" },
    { pattern = "'\\?.'", type = "string" },

    -- interpolated normal string
    { pattern = [[%$"[^"\n]*"]], type = "string" },

    -- interpolated verbatim string
    { pattern = [[%$@"[^"]*"]], type = "string" },

    -- interpolated triple quote
    { pattern = [[%$@?"""[^"]-"""]], type = "string" },

    -- numbers
    { pattern = "-?0x%x+", type = "number" },
    { pattern = "-?%d+[%d%.eE]*", type = "number" },
    { pattern = "-?%.?%d+", type = "number" },

    -- operators
    { pattern = "%-%>", type = "operator" },   -- ->
    { pattern = "[%+%-=/%*%^%%<>!~|&@:]", type = "operator" },

    -- active patterns (|A|B|)
    { pattern = "%(%|[%a_][%w_]*%|[%a_][%w_]*%|%)", type = "function" },

    -- functions
    { pattern = "[%a_][%w_]*%f[(]", type = "function" },

    -- identifiers
    { pattern = "[%a_][%w_']*", type = "symbol" },

    -- etc.
    { regex = [[%w+%s*%()]], type = "function" },
    { regex = [[%w+%s*%[?<\'?%w+>%]?]], type = { "function", "keyword2" } },
    { regex = [[#\w+]], type = "keyword2" },
    { regex = [['\w+]], type = "keyword2" },
  },

  symbols = {
    ["yield!"]     = "keyword",
    ["yield"]      = "keyword",
    ["with"]       = "keyword",
    ["while"]      = "keyword",
    ["when"]       = "keyword",
    ["void"]       = "keyword",
    ["val"]        = "keyword",
    ["use!"]       = "keyword",
    ["use"]        = "keyword",
    ["upcast"]     = "keyword",
    ["unativeint"] = "keyword",
    ["uint64"]     = "keyword",
    ["uint32"]     = "keyword",
    ["uint16"]     = "keyword",
    ["uint"]       = "keyword",
    ["type"]       = "keyword",
    ["try"]        = "keyword",
    ["to"]         = "keyword",
    ["then"]       = "keyword",
    ["struct"]     = "keyword",
    ["static"]     = "keyword",
    ["single"]     = "keyword",
    ["sbyte"]      = "keyword",
    ["return!"]    = "keyword",
    ["return"]     = "keyword",
    ["rec"]        = "keyword",
    ["raise"]      = "keyword",
    ["public"]     = "keyword",
    ["private"]    = "keyword",
    ["printfn"]    = "keyword",
    ["override"]   = "keyword",
    ["or"]         = "keyword",
    ["open"]       = "keyword",
    ["of"]         = "keyword",
    ["not"]        = "keyword",
    ["new"]        = "keyword",
    ["nativeint"]  = "keyword",
    ["namespace"]  = "keyword",
    ["mutable"]    = "keyword",
    ["module"]     = "keyword",
    ["member"]     = "keyword",
    ["match"]      = "keyword",
    ["let!"]       = "keyword",
    ["let"]        = "keyword",
    ["invalidArg"] = "keyword",
    ["internal"]   = "keyword",
    ["interface"]  = "keyword",
    ["int16"]      = "keyword",
    ["inline"]     = "keyword",
    ["inherit"]    = "keyword",
    ["in"]         = "keyword",
    ["if"]         = "keyword",
    ["global"]     = "keyword",
    ["function"]   = "keyword",
    ["fun"]        = "keyword",
    ["for"]        = "keyword",
    ["float32"]    = "keyword",
    ["fixed"]      = "keyword",
    ["finally"]    = "keyword",
    ["extern"]     = "keyword",
    ["exception"]  = "keyword",
    ["enum"]       = "keyword",
    ["end"]        = "keyword",
    ["else"]       = "keyword",
    ["elif"]       = "keyword",
    ["downto"]     = "keyword",
    ["downcast"]   = "keyword",
    ["do!"]        = "keyword",
    ["do"]         = "keyword",
    ["contains"]   = "keyword",
    ["class"]      = "keyword",
    ["bigint"]     = "keyword",
    ["begin"]      = "keyword",
    ["assert"]     = "keyword",
    ["as"]         = "keyword",
    ["and"]        = "keyword",
    ["add"]        = "keyword",
    ["abstract"]   = "keyword",
    ["String"]     = "keyword",
    ["Char"]       = "keyword",


    ["unit"]       = "keyword2",
    ["string"]     = "keyword2",
    ["seq"]        = "keyword2",
    ["option"]     = "keyword2",
    ["obj"]        = "keyword2",
    ["list"]       = "keyword2",
    ["int64"]      = "keyword2",
    ["int32"]      = "keyword2",
    ["int"]        = "keyword2",
    ["float"]      = "keyword2",
    ["double"]     = "keyword2",
    ["decimal"]    = "keyword2",
    ["char"]       = "keyword2",
    ["byte"]       = "keyword2",
    ["bool"]       = "keyword2",
    ["array"]      = "keyword2",


    ["true"]       = "literal",
    ["null"]       = "literal",
    ["false"]      = "literal",
  }
}
