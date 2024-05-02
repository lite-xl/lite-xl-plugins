-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
  name = "Conf",
  files = { ".gitconfig", ".rclone.conf", "%.conf$" },
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
    -- Git
    { pattern = "HEAD", type = "literal" },
    -- Rclone AWS S3 canned ACLs
    { pattern = "private", type="literal" },
    { pattern = "public%-read", type="literal" },
    { pattern = "public%-read%-write", type="literal" },
    { pattern = "aws%-exec%-read", type="literal" },
    { pattern = "authenticated%-read", type="literal" },
    { pattern = "bucket%-owner%-read", type="literal" },
    { pattern = "bucket%-owner%-full%-control", type="literal" },
    { pattern = "log%-delivery%-write", type="literal" },
  },
  symbols = {
    -- Git
    ["true"] = "literal",
    ["false"] = "literal",
    ["auto"] = "literal",
    ["main"] = "literal",
    ["master"] = "literal",
    ["origin"] = "literal",
    ["remote"] = "literal",
    ["local"] = "literal",
    ["always"] = "literal",
    ["format"] = "literal",
  },
}

