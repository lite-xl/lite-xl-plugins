-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "GraphQL",
  files = { "%.graphql$", "%.gql$" },
  comment = "#",
  block_comment = { '"""', '"""' },
  patterns = {
    { pattern = { '"""', '"""' },                          type = "comment"  },
    { pattern = "#.*",                                     type = "comment"  },
    { pattern = { '"', '"', "\\" },                        type = "string"   },
    { pattern = "-?%.?%d+",                                type = "number"   },
    { pattern = "%s*[@]%s*[%a_][%w_]*",                    type = "function" },
    { pattern = "!",                                       type = "operator" },
    { pattern = "%s*=%s*",                                 type = "operator" },
    { pattern = "%s*%$[%a_][%w_]*:*",                      type = "literal"  },
    { pattern = "query%s*()[%a_][%w_]*[(]",                type = { "keyword", "function" } },
    { pattern = "mutation%s*()[%a_][%w_]*[(]",             type = { "keyword", "function" } },
    { pattern = ":%s*%[*()[%a_,%s][%w_,%s]*()%]*()[!]*",   type = { "symbol", "literal", "symbol", "operator" } },
  },
  symbols = {
    ["query"]         = "keyword",
    ["mutation"]      = "keyword",
    ["type"]          = "keyword",
    ["interface"]     = "keyword",
    ["input"]         = "keyword",
    ["fragment"]      = "keyword",
    ["directive"]     = "keyword",
    ["extends"]       = "keyword",
    ["implements"]    = "keyword",
    ["on"]            = "keyword",
    ["enum"]          = "keyword",
    ["scalar"]        = "keyword",
    ["union"]         = "keyword",
    ["schema"]        = "keyword",
    ["extend"]        = "keyword2",
    ["true"]          = "literal",
    ["false"]         = "literal",
  },
}

