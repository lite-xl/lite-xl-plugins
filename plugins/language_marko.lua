-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax References
-- https://markojs.com/docs/syntax/

syntax.add {
    name = "Marko JS",
    files = { "%.marko$" },
    comment = "//",
    block_comment = { "<!%-%-", "%-%->" },
    patterns = {
        { pattern = { "%-%-\n", "%-%-" },   type = "string" },   -- Multiline string
        { pattern = "%-%-.-\n",             type = "string" },   -- Single line string
        { pattern = "^%s*%a[%w%-_]*",       type = "keyword" },  -- Concise formatting keywords
        { pattern = "//.*",                 type = "comment" },  -- Single line js/ts based comments
        { pattern = { "/%*", "%*/" },       type = "comment" },  -- Multiline js/ts based comments
        { pattern = { "<!%-%-", "%-%->" },  type = "comment" },  -- Multiline Marko/HTML based comments
        { pattern = "<!%a[%w%-_%s*]*>",     type = "comment" },  -- CDATA like <!doctype html>
        { pattern = { '"', '"', '\\' },     type = "string" },   -- String for attribute and js/ts based syntax
        { pattern = { "'", "'", '\\' },     type = "string" },   -- String for attribute and js/ts based syntax
        { pattern = "0x[%da-fA-F]+",        type = "number" },   -- Number
        { pattern = "-?%d+[%d%.eE]*",       type = "number" },   -- Number
        { pattern = "-?%.?%d+",             type = "number" },   -- Number
        { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" }, -- Operators
        { pattern = "^[$]",                 type = "keyword2" }, -- for $ declaration at start of line
        { pattern = "<%a[%w%-_]*",          type = "keyword" },  -- HTML opening tags like syntax Marko
        { pattern = "</%a[%w%-_]*>",        type = "keyword" },  -- HTML closing tags like syntax Marko
        { pattern = "${%a[%w%-_%.]*}",      type = "keyword2" }, -- line insertion markojs
        { pattern = "$!{%a[%w%-_%.]*}",     type = "keyword2" }, -- unsafe line insertion markojs
        { pattern = "/>",                   type = "keyword" },  -- closing tag for multi line based html opening tag
        { pattern = "%[",                   type = "keyword" },  -- opening tag for multi line based marko consice syntax
        { pattern = "%]",                   type = "keyword" },  -- closing tag for multi line based marko consice syntax
        { pattern = "[%a_][%w_]*%f[(]",     type = "function" }, -- JS/TS based function declarations
        { pattern = "[%a_][%w%-_]*",        type = "symbol" },   -- Symbol
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
