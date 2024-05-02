-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
  name = "Conf",
  files = { ".rclone.conf", ".gitconfig", "%.conf$" },
  comment = '#',
  patterns = {
    { pattern = ";.-\n", type = "comment" },
    { pattern = "#.-\n", type = "comment" },
    { pattern = { "%[", "%]" }, type = "keyword" },

    { pattern = { '"""', '"""', '\\' }, type = "string" },
    { pattern = { '"', '"', '\\' }, type = "string" },
    { pattern = { "'''", "'''" }, type = "string" },
    { pattern = { "'", "'" }, type = "string" },
    { pattern = "[A-Za-z0-9_%.%-]+%s*%f[=]", type = "function" },
    { pattern = "%s+%-%-[A-Za-z0-9%-]+", type = "normal" },
    { pattern = "[a-z]+", type = "symbol" },
    { pattern = "HEAD+", type = "symbol" },
  },
  symbols = {
    -- Git
    ["true"] = "literal",
    ["false"] = "literal",
    ["auto"] = "literal",
    ["HEAD"] = "literal",
    ["main"] = "literal",
    ["master"] = "literal",
    ["origin"] = "literal",
    ["remote"] = "literal",
    ["local"] = "literal",
    ["always"] = "literal",
    ["format"] = "literal",
  },
}

