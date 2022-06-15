-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  files = { "Caddyfile" },
  comment = "#",
  patterns = {
    { pattern = { "#", "\n"},          type = "comment"  },
    { pattern = { '"', '"', '\\' },    type = "string"   },
    -- Matcher definition
    { pattern = "@[%w_]+",             type = "operator" },
    -- Snippet
    { pattern = "%(%g+%)",             type = "operator" },
    -- Properties
    { pattern = "^[%a_][%w_]*()%s+%f[%g]",
      type = { "function", "normal" }
    },
    { pattern = "^[%a_][%w_]*()%s+$",
      type = { "function", "normal" }
    },
    { pattern = "^%s*()[%a_][%w_]*()%s+$",
      type = { "normal", "function", "normal" }
    },
    { pattern = "^%s*()[%a_][%w_]*()%s+%f[%g]",
      type = { "normal", "function", "normal" }
    },
    -- Environment variables
    { pattern = "{()%$[%w_]+():()[%w_]+()}",
      type = { "operator", "keyword2", "operator", "keyword2", "operator" }
    },
    { pattern = "{()%$[%w_]+()}",
      type = { "operator", "keyword2", "operator" }
    },
    -- Place holder
    { pattern = "{%g-}",               type = "keyword2"  },
    -- Operators
    { pattern = "[+%-,:]",             type = "operator" },
    -- IP Address
    { pattern = "%d+%.%d+%.%d+%.%d+",  type = "literal"  },
    -- Path /path/subpath
    { pattern = "/[%w%./]+",           type = "literal"  },
    -- Wildcard domain *.levels
    { pattern = "%*()[%w.]+",
      type = { "operator", "literal" }
    },
    -- Match Operator
    { pattern = "%*+",                 type = "operator" },
    -- Domain leve1.level2
    { pattern = "https?://[%w%./%*]+", type = "literal"  },
    -- Domain leve1.level2
    { pattern = "%w+%.[%w%.]+",        type = "literal"  },
    -- Number
    { pattern = "%d+[mhskbi]*",        type = "number"   },
    -- Everything else for symbols to work
    { pattern = "[%a_][%w_]*",         type = "symbol"   },
  },
  symbols = {
    ["true"] = "literal",
    ["false"] = "literal",
    ["localhost"] = "literal",

    -- built-in directives
    ["abort"] = "keyword",
    ["acme_server"] = "keyword",
    ["basicauth"] = "keyword",
    ["bind"] = "keyword",
    ["encode"] = "keyword",
    ["error"] = "keyword",
    ["file_server"] = "keyword",
    ["forward_auth"] = "keyword",
    ["handle"] = "keyword",
    ["handle_errors"] = "keyword",
    ["handle_path"] = "keyword",
    ["header"] = "keyword",
    ["import"] = "keyword",
    ["log"] = "keyword",
    ["method"] = "keyword",
    ["map"] = "keyword",
    ["metrics"] = "keyword",
    ["php_fastcgi"] = "keyword",
    ["push"] = "keyword",
    ["redir"] = "keyword",
    ["request_body"] = "keyword",
    ["request_header"] = "keyword",
    ["respond"] = "keyword",
    ["reverse_proxy"] = "keyword",
    ["rewrite"] = "keyword",
    ["root"] = "keyword",
    ["route"] = "keyword",
    ["templates"] = "keyword",
    ["tls"] = "keyword",
    ["tracing"] = "keyword",
    ["try_files"] = "keyword",
    ["uri"] = "keyword",
    ["vars"] = "keyword",

    -- Module directives
    ["cgi"] = "keyword",
    ["ssh"] = "keyword",
    ["exec"] = "keyword",
    ["supervisor"] = "keyword",
    ["layer4"] = "keyword",
  },
}
