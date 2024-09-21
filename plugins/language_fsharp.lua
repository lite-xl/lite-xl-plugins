-- mod-version:3
local syntax = require "core.syntax"

-- https://learn.microsoft.com/en-us/dotnet/fsharp/language-reference/

-- WIP: https://learn.microsoft.com/en-us/dotnet/fsharp/language-reference/slices#defining-slices-for-other-data-structures

syntax.add {
  name = "F#",
  files = { "%.fsi?$" },
  comment = "//",
  block_comment = { "(*", "*)" },
  patterns = {
    { pattern = "//.*",                                        type = "comment"   }, -- Single-line comment
    { pattern = { "%(%*", "%*%)" },                            type = "comment"   }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },                            type = "string"    }, -- String, quotation marks
    { regex   = "\\${1,2}(?=\"?\'?)",                          type = "string"    }, -- String, $
    { regex   = "-?(?:\\d_?)+(?:.\\d+)?(?:e|E\\+\\^\\d+)?",    type = "number"    }, -- Numbers
    { regex   = "-?0x[0-9a-fA-F]+",                            type = "number"    }, -- Exadecimal Numbers
    { regex   = "\\<.+\\>",                                    type = "keyword2"  }, -- Generic type
    { regex   = "\\[\\<.+\\>\\]",                              type = "keyword2"  }, -- Attribute
    { regex   = "\\:\\s?\\w+",                                 type = "keyword2"  }, -- Type
    { regex   = "\\_(?=\\s?\\:)",                              type = "normal"    }, -- _ should be normal when used as ?
    { pattern = "[%+%-=/%*%^%%<>!~|&_:@]",                     type = "operator"  }, -- Operators
    { regex   = [[\.{2}\<?\s?(?=[\\-]?[a-z0-9])]],             type = "operator"  }, -- Range operators
    { regex   = [[\-\>(?=\s)]],                                type = "function"  }, -- Function arrow
    { regex   = "\\w+(?=\\s*[(])",                             type = "function"  }, -- Function without generic type
    { regex   = "\\w+()\\s?\\[?\\<\\'?\\w+\\>\\]?",            type = { "function", "keyword2" } }, -- Function with generic type
    { regex   = "\\#\\w+",                                     type = "keyword2"  }, -- Load
    { regex   = "\\'\\w+",                                     type = "keyword2"  }, -- Special variable
    { pattern = "[%a_][%w_]*",                                 type = "symbol"    }, -- Words
    -- FIX: """{"numbers":[1,2,3,4,5]}"""
    -- FIX: @"<book author=""Milton, John"" title=""Paradise Lost"">"
    -- FIX: $"""string-text {"embedded string literal"}"""
    -- FIX: $"""Name: {"Phillip"}, Age: %d{age}"""
    -- FIX: 2.3E+32
    -- FIX: 2.3e+32
    -- FIX: 100u
    -- FIX: 0o77
    -- FIX: 0b1010
    -- FIX: 0xDEAD_BEEF
    -- FIX: 0b1101_1110_1010_1101_1011_1110_1110_1111
    -- FIX: 123_45_6789
    -- FIX: add pattern for functions without (): function1 x y
    -- FIX: add pattern for methods without (): .get p 0
    -- FIX: update range pattern for [| 1.. 100 |]
    -- TODO: add range pattern for 1..10 or 1 .. 10
    -- FIX: 'a' .. 'z'
    -- FIX: < var2 -> should be properly colored
    -- FIX: the :: should be operator-colored in the following: head :: tail
    -- FIX: : System.IO.StreamReader should be properly colored
    -- FIX: Collections.seq<_> should be colored as type
    -- FIX: In abstract abstractMethod<'a, 'b> : 'a * 'b -> unit the -> should colored as operators
    -- FIX: in the val concat: sequences:seq<#seq<'T>> -> seq<'T> example, the -> should be colored as operator
    -- FIX: let convertg2kg (x : float<g>) = x / 1000.0<g/kg>
    -- FIX: in System.Char.IsUpper , Char should not be colored
    -- FIX: int array should be colored fully as type
  },
  symbols = {
    ["sbyte"]          = "keyword",
    ["byte"]           = "keyword",
    ["int16"]          = "keyword",
    ["uint16"]         = "keyword",
    ["int"]            = "keyword",
    ["uint"]           = "keyword",
    ["int32"]          = "keyword",
    ["uint32"]         = "keyword",
    ["nativeint"]      = "keyword",
    ["unativeint"]     = "keyword",
    ["int64"]          = "keyword",
    ["uint64"]         = "keyword",
    ["single"]         = "keyword",
    ["float32"]        = "keyword",
    ["double"]         = "keyword",
    ["bigint"]         = "keyword",
    ["decimal"]        = "keyword",
    ["Char"]           = "keyword",
    ["String"]         = "keyword",
    ["bool"]           = "keyword",
    ["char"]           = "keyword",
    ["string"]         = "keyword",
    ["unit"]           = "keyword",
    ["enum"]           = "keyword",
    ["fixed"]          = "keyword",
    
    ["let"]            = "keyword",
    ["type"]           = "keyword",
    ["when"]           = "keyword",
    ["module"]         = "keyword",
    ["member"]         = "keyword",
    ["interface"]      = "keyword",
    ["match"]          = "keyword",
    ["with"]           = "keyword",
    ["printfn"]        = "keyword",
    ["if"]             = "keyword",
    ["then"]           = "keyword",
    ["elif"]           = "keyword",
    ["else"]           = "keyword",
    ["extern"]         = "keyword",
    ["void"]           = "keyword",
    ["mutable"]        = "keyword",
    ["do"]             = "keyword",
    ["open"]           = "keyword",
    ["use"]            = "keyword",
    ["rec"]            = "keyword",
    ["fun"]            = "keyword",
    ["static"]         = "keyword",
    ["inline"]         = "keyword",
    ["for"]            = "keyword",
    ["to"]             = "keyword",
    ["downto"]         = "keyword",
    ["and"]            = "keyword",
    ["or"]             = "keyword",
    ["in"]             = "keyword",
    ["while"]          = "keyword",
    ["as"]             = "keyword",
    ["class"]          = "keyword",
    ["end"]            = "keyword",
    ["inherit"]        = "keyword",
    ["exception"]      = "keyword",
    ["of"]             = "keyword",
    ["yield"]          = "keyword",
    ["try"]            = "keyword",
    ["finally"]        = "keyword",
    ["invalidArg"]     = "keyword",
    ["assert"]         = "keyword",
    ["abstract"]       = "keyword",
    ["upcast"]         = "keyword",
    ["downcast"]       = "keyword",
    ["override"]       = "keyword",
    ["add"]            = "keyword",
    ["contains"]       = "keyword",
    ["not"]            = "keyword",
    ["struct"]         = "keyword",
    ["namespace"]      = "keyword",
    ["global"]         = "keyword",
    ["private"]        = "keyword",
    ["public"]        = "keyword",
    ["internal"]       = "keyword",
    ["val"]            = "keyword",

    ["true"]           = "literal",
    ["false"]          = "literal",
  }
}
