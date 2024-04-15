-- Author: Rohan Vashisht: https://github.com/rohanvashisht1234/


-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
    name = "Swift",
    files = { "%.swift$" },
    comment = "//",
    patterns = {
        { pattern = { '"', '"', '\\' },         type = "string" },                           -- tested ok
        { pattern = { '"""', '"""', '\\' },     type = "string" },                           -- tested ok
        { pattern = { '#"', '"#', '\\' },       type = "string" },                           -- tested ok
        { pattern = { '#"""', '"""#', '\\' },   type = "string" },                           -- tested ok
        { pattern = "//.*",                     type = "comment" },                          -- tested ok
        { pattern = { "/%*", "%*/" },           type = "comment" },                          -- tested ok
        { pattern = "[!%-/*?:=><+]",            type = "operator" },                         -- tested ok
        { pattern = "[%a_][%w_]*%f[(]",         type = "function" },                         -- tested ok
        { pattern = "let()%s+()[%a_][%w_]*",    type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "var()%s+()[%a_][%w_]*",    type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "import()%s+()[%a_][%w_]*", type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "struct()%s+()[%a_][%w_]*", type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "class()%s+()[%a_][%w_]*",  type = { "keyword", "normal", "literal" } }, -- tested ok
        { pattern = "enum()%s+()[%a_][%w_]*",   type = { "keyword", "normal", "literal" } }, -- tested ok

        { pattern = "-?%d+[%d%.eE_]*",          type = "number" },                           -- tested ok
        { pattern = "-?%.?%d+",                 type = "number" },                           -- tested ok
        { pattern = "[%a_][%w_]*",              type = "normal" },                           -- tested ok
    },
    symbols = {
        ["import"]          = "keyword",  -- tested ok
        ["inout"]           = "keyword",  -- tested ok
        ["internal"]        = "keyword",  -- tested ok
        ["let"]             = "keyword",  -- tested ok
        ["Let"]             = "keyword",  -- tested ok
        ["open"]            = "keyword",  -- tested ok
        ["operator"]        = "keyword",  -- tested ok
        ["private"]         = "keyword",  -- tested ok
        ["precedencegroup"] = "keyword",  -- tested ok
        ["protocol"]        = "keyword",  -- tested ok
        ["public"]          = "keyword",  -- tested ok
        ["rethrows"]        = "keyword",  -- tested ok
        ["static"]          = "keyword",  -- tested ok
        ["struct"]          = "keyword",  -- tested ok
        ["subscript"]       = "keyword",  -- tested ok
        ["typealias"]       = "keyword",  -- tested ok
        ["var"]             = "keyword",  -- tested ok
        ["break"]           = "keyword",  -- tested ok
        ["while"]           = "keyword",  -- tested ok
        ["nil"]             = "keyword",  -- tested ok
        ["associativity"]   = "keyword",  -- tested ok
        ["convenience"]     = "keyword",  -- tested ok
        ["didSet"]          = "keyword",  -- tested ok
        ["dynamic"]         = "keyword",  -- tested ok
        ["final"]           = "keyword",  -- tested ok
        ["get"]             = "keyword",  -- tested ok
        ["indirect"]        = "keyword",  -- tested ok
        ["infix"]           = "keyword",  -- tested ok
        ["left"]            = "keyword",  -- tested ok
        ["mutating"]        = "keyword",  -- tested ok
        ["none"]            = "keyword",  -- tested ok
        ["nonmutating"]     = "keyword",  -- tested ok
        ["optional"]        = "keyword",  -- tested ok
        ["override"]        = "keyword",  -- tested ok
        ["postfix"]         = "keyword",  -- tested ok
        ["Protocol"]        = "keyword",  -- tested ok
        ["required"]        = "keyword",  -- tested ok
        ["right"]           = "keyword",  -- tested ok
        ["set"]             = "keyword",  -- tested ok
        ["some"]            = "keyword",  -- tested ok
        ["Type"]            = "keyword",  -- tested ok
        ["unowned"]         = "keyword",  -- tested ok
        ["weak"]            = "keyword",  -- tested ok
        ["lazy"]            = "keyword",  -- tested ok
        ["prefix"]          = "keyword",  -- tested ok
        ["willSet"]         = "keyword",  -- tested ok
        ["try"]             = "keyword",  -- tested ok
        ["true"]            = "keyword",  -- tested ok
        ["throws"]          = "keyword",  -- tested ok
        ["super"]           = "keyword",  -- tested ok
        ["Self"]            = "keyword",  -- tested ok
        ["self"]            = "keyword",  -- tested ok
        ["is"]              = "keyword",  -- tested ok
        ["false"]           = "keyword",  -- tested ok
        ["as"]              = "keyword",  -- tested ok
        ["Any"]             = "keyword",  -- tested ok
        ["where"]           = "keyword",  -- tested ok
        ["switch"]          = "keyword",  -- tested ok
        ["throw"]           = "keyword",  -- tested ok
        ["catch"]           = "keyword",  -- tested ok
        ["return"]          = "keyword",  -- tested ok
        ["repeat"]          = "keyword",  -- tested ok
        ["in"]              = "keyword",  -- tested ok
        ["if"]              = "keyword",  -- tested ok
        ["gaurd"]           = "keyword",  -- tested ok
        ["for"]             = "keyword",  -- tested ok
        ["fallthrough"]     = "keyword",  -- tested ok
        ["else"]            = "keyword",  -- tested ok
        ["do"]              = "keyword",  -- tested ok
        ["defer"]           = "keyword",  -- tested ok
        ["default"]         = "keyword",  -- tested ok
        ["continue"]        = "keyword",  -- tested ok
        ["case"]            = "keyword",  -- tested ok
        ["init"]            = "keyword",  -- tested ok
        ["func"]            = "keyword",  -- tested ok
        ["fileprivate"]     = "keyword",  -- tested ok
        ["extension"]       = "keyword",  -- tested ok
        ["associatedtype"]  = "keyword",  -- tested ok
        ["enum"]            = "keyword",  -- tested ok
        ["Init"]            = "keyword",  -- tested ok
        ["Enum"]            = "keyword",  -- tested ok
        ["deinit"]          = "keyword",  -- tested ok
        ["class"]           = "keyword",  -- tested ok
        ["Class"]           = "keyword",  -- tested ok
        ["precedence"]      = "keyword",  -- tested ok

        ["#available"]      = "keyword2", -- tested ok
        ["#colorLiteral"]   = "keyword2", -- tested ok
        ["#column"]         = "keyword2", -- tested ok
        ["#dsohandle"]      = "keyword2", -- tested ok
        ["#elseif"]         = "keyword2", -- tested ok
        ["#else"]           = "keyword2", -- tested ok
        ["#endif"]          = "keyword2", -- tested ok
        ["#error"]          = "keyword2", -- tested ok
        ["#keyPath"]        = "keyword2", -- tested ok
        ["#line"]           = "keyword2", -- tested ok
        ["#selector"]       = "keyword2", -- tested ok
        ["#sourceLocation"] = "keyword2", -- tested ok
        ["#warning"]        = "keyword2", -- tested ok
        ["_COLUMN_"]        = "keyword2", -- tested ok
        ["_FILE_"]          = "keyword2", -- tested ok
        ["_FUNCTION_"]      = "keyword2", -- tested ok
        ["_LINE_"]          = "keyword2", -- tested ok
        ["String"]          = "keyword2", -- tested ok
        ["Int"]             = "keyword2", -- tested ok
        ["Int8"]            = "keyword2", -- tested ok
        ["Int16"]           = "keyword2", -- tested ok
        ["Int32"]           = "keyword2", -- tested ok
        ["Int64"]           = "keyword2", -- tested ok
        ["UInt8"]           = "keyword2", -- tested ok
        ["UInt16"]          = "keyword2", -- tested ok
        ["UInt32"]          = "keyword2", -- tested ok
        ["UInt64"]          = "keyword2", -- tested ok
        ["Float"]           = "keyword2", -- tested ok
        ["Bool"]            = "keyword2", -- tested ok
        ["at"]              = "keyword2", -- tested ok
    }
}
