-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "F#",
  files = { "%.fsi?$" },
  comment = "//",
  patterns = {
    { pattern = "//.*",                                type = "comment"   }, -- Single-line comment
    { pattern = { '"', '"', '\\' },                    type = "string"    }, -- String, quotation marks
    { regex   = "\\${1,2}(?=\"?\'?)",                  type = "string"    }, -- String, $
    { pattern = "-?0x%x+",                             type = "number"    }, -- ?
    { pattern = "-?%d+[%deE]*f?",                      type = "number"    }, -- ?
    { pattern = "-?%.?%d+f?",                          type = "number"    }, -- ?
    { regex   = "\\<.+\\>",                            type = "keyword2"  }, -- Generic type
    { regex   = "\\[\\<.+\\>\\]",                      type = "keyword2"  }, -- Attribute
    { regex   = "\\:\\s?\\w+",                         type = "keyword2"  }, -- Type
    { regex   = "\\_(?=\\s?\\:)",                      type = "normal"    }, -- _ should be normal when used as ?
    { pattern = "[%+%-=/%*%^%%<>!~|&_:]",              type = "operator"  }, -- Operators
    { regex   = [[\.{2}\<?\s?(?=[\\-]?[a-z0-9])]],     type = "operator"  }, -- Range operators
    { regex   = [[\-\>(?=\s)]],                        type = "function"  }, -- Function arrow
    { regex   = "\\w+(?=\\s?[(])",                     type = "function"  }, -- Function without generic type
    { regex   = "\\w+()\\s?\\[?\\<\\'?\\w+\\>\\]?",    type = { "function", "keyword2" } }, -- Function with generic type
    { regex   = "\\#\\w+",                             type = "keyword2"  }, -- Load
    { regex   = "\\'\\w+",                             type = "keyword"   }, -- Special variable
  },
  symbols = {
    ["sbyte"]          = "keyword",
    ["byte"]           = "keyword",
    ["int16"]          = "keyword",
    ["uint16"]         = "keyword",
    ["int"]            = "keyword",
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
    ["not"]            = "keyword",
    ["struct"]         = "keyword",
    ["namespace"]      = "keyword",
    ["global"]         = "keyword",
    ["private"]        = "keyword",
    ["internal"]       = "keyword",
    ["val"]            = "keyword",

    ["true"]           = "literal",
    ["false"]          = "literal",
  },
}
