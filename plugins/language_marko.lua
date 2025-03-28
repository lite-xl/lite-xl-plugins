-- Made by: https://github.com/rohanvashisht1234

-- mod-version:3
-- Syntax definition for Marko.js

local syntax = require "core.syntax"

syntax.add {
    name = "Marko",
    files = { "%.marko$" },
    comment = "//",
    patterns = {
        -- Important
        { pattern = { "%-%-\n", "%-%-" },   type = "string" }, -- Multiline string
        { pattern = "%-%-.-\n",             type = "string" }, -- Single line string
        { pattern = "^%s*%a[%w%-_]*",       type = "keyword" },

        -- Comments
        { pattern = "//.-\n",               type = "comment" },
        { pattern = { "/%*", "%*/" },       type = "comment" },
        { pattern = { "<!%-%-", "%-%->" },  type = "comment" },



        -- CDATA
        { pattern = "<!%a[%w%-_%s*]*>",     type = "comment" },

        -- Strings
        { pattern = { '"', '"', '\\' },     type = "string" },
        { pattern = { "'", "'", '\\' },     type = "string" },

        -- Numbers
        { pattern = "0x[%da-fA-F]+",        type = "number" },
        { pattern = "-?%d+[%d%.eE]*",       type = "number" },
        { pattern = "-?%.?%d+",             type = "number" },

        -- Operators
        { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" },
        { pattern = "^[$]",                 type = "keyword2" },


        -- Marko-specific patterns
        { pattern = "<%a[%w%-_]*",          type = "keyword" },

        { pattern = "</%a[%w%-_]*>",        type = "keyword" },
        { pattern = "${%a[%w%-_%.]*}",      type = "keyword2" },
        { pattern = "/>",                   type = "keyword" },
        { pattern = "%[",                   type = "keyword" },
        { pattern = "%]",                   type = "keyword" },

        -- Attributes
        { pattern = "[%a_][%w%-_]*%s*=",    type = "keyword2" },

        -- Functions and symbols
        { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
        { pattern = "[%a_][%w%-_]*",        type = "symbol" },
    },
    symbols = {

        ["class"]           = "keyword2",
        ["style"]           = "keyword2",
        ["src"]             = "keyword2",
        ["href"]            = "keyword2",
        ["alt"]             = "keyword2",
        ["width"]           = "keyword2",
        ["height"]          = "keyword2",
        ["loading"]         = "keyword2",
        ["decoding"]        = "keyword2",
        ["allow"]           = "keyword2",
        ["allowfullscreen"] = "keyword2",
        ["frameborder"]     = "keyword2",
        ["referrerpolicy"]  = "keyword2",
        ["const"]           = "keyword",
        ["function"]        = "keyword",
        ["if"]              = "keyword",
        ["import"]          = "keyword",
        ["let"]             = "keyword",
        ["return"]          = "keyword",
        ["static"]          = "keyword",
        ["true"]            = "literal",
        ["false"]           = "literal",
        ["null"]            = "literal",
        ["undefined"]       = "literal",
    },
}
