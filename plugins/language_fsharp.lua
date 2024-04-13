-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "FSharp",
  files = { "%.fs$" },
  comment = "//",
  patterns = {
    { pattern = "//.*",                          type = "comment"   }, -- Single-line comment
    { pattern = { '"', '"', '\\' },              type = "string"    }, -- String, quotation marks
    { regex   = "\'[a-zA-Z]",                    type = "symbol"    }, -- ?
    { pattern = { "'", "'", '\\' },              type = "string"    }, -- String, apices
    { regex   = "\\${1,2}(?=\"?\'?)",            type = "string"    }, -- String, $
    { pattern = "-?0x%x+",                       type = "number"    }, -- ?
    { pattern = "-?%d+[%deE]*f?",                type = "number"    }, -- ?
    { pattern = "-?%.?%d+f?",                    type = "number"    }, -- ?
    { pattern = "[%+%-=/%*%^%%<>!~|&]",          type = "operator"  }, -- Operators
    { regex   = [[\-\>(?=\s)]],                  type = "operator"  }, -- Function arrow
    { regex   = "[a-zA-Z0-9]+\\s?(?=[(])",       type = "function"  }, -- Function
    -- TODO: generic type
    -- TODO: named literal
    -- TODO: field type
    -- TODO: attributes (e.g. [<InlineIfLambda>])
  },
  symbols = {
    ["sbyte"]          = "literal",
    ["byte"]           = "literal",
    ["int16"]          = "literal",
    ["uint16"]         = "literal",
    ["int"]            = "literal",
    ["int32"]          = "literal",
    ["uint32"]         = "literal",
    ["nativeint"]      = "literal",
    ["unativeint"]     = "literal",
    ["int64"]          = "literal",
    ["uint64"]         = "literal",
    ["single"]         = "literal",
    ["float32"]        = "literal",
    ["double"]         = "literal",
    ["bigint"]         = "literal",
    ["decimal"]        = "literal",
    ["Char"]           = "literal",
    ["String"]         = "literal",
    ["bool"]           = "literal",
    ["char"]           = "literal",
    ["string"]         = "literal",
    ["unit"]           = "literal",
    ["enum"]           = "literal",
    
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
    ["downcast"]       = "keyword",
    ["override"]       = "keyword",
    ["add"]            = "keyword",
    ["contains"]       = "keyword",

    ["true"]           = "literal",
    ["false"]          = "literal",
  },
}
