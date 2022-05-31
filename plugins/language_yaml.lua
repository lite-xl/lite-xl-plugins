-- mod-version:3
local syntax = require "core.syntax"

local yaml_bracket_list = {
  patterns = {
    -- comments
    { pattern = { "#", "\n"},                  type = "comment"  },
    -- strings
    { pattern = { '"', '"', '\\' },            type = "string"   },
    { pattern = { "'", "'", '\\' },            type = "string"   },
    -- keys
    {
      pattern = "[%w%d]+%g+()%s*():()%s",
      type = { "keyword2", "normal", "operator", "normal" }
    },
     -- variables
    { pattern = "%$%a%w+",                     type = "keyword"  },
    { pattern = "%$%{%{.-%}%}",                type = "keyword"  },
    -- numeric place holders
    { pattern = "%-?%.inf",                    type = "number"   },
    { pattern = "%.NaN",                       type = "number"   },
    -- numbers
    { pattern = "[%+%-]?0%d+",                 type = "number"   },
    { pattern = "[%+%-]?0x%x+",                type = "number"   },
    { pattern = "[%+%-]?%d+[,%.eE:%+%d]*%d+",  type = "number"   },
    { pattern = "[%+%-]?%d+",                  type = "number"   },
    -- others
    { pattern = ",",                           type = "operator" },
    { pattern = "%w+",                         type = "string"   },
    {
      pattern = "[_%(%)%*@~`!%%%^&=%+%-\\;%.><%?/%s]+",
      type = "string"
    }
  },
  symbols = {}
}

syntax.add {
  name = "YAML",
  files = { "%.yml$", "%.yaml$" },
  comment = "#",
  space_handling = false,
  patterns = {
  --- rules that start with spaces first and those taking precedence
    -- parent and child keys
    {
      pattern = "^[%w%d]+%g+%s*%f[:]",
      type = "literal"
    },
    {
      pattern = "^%s+[%w%d]+%g+%s*%f[:]",
      type = "keyword2"
    },
    -- bracket lists after key declaration
    {
      pattern = { ":%s+%[", "%]" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { ":%s+{", "}" },
      syntax = yaml_bracket_list, type = "operator"
    },
    -- child key
    {
      pattern = "^%s+()[%w%d]+%g+()%s*():()%s",
      type = { "normal", "keyword2", "normal", "operator", "normal" }
    },
    -- child list element
    {
      pattern = "^%s+()%-()%s+()[%w%d]+%g+()%s*():()%s",
      type = { "normal", "operator", "normal", "keyword2", "normal", "operator", "normal" }
    },
    -- unkeyed bracket lists
    {
      pattern = { "^%s*%[", "%]" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "^%s*{", "}" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "^%s*%-%s*%[", "%]" },
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "^%s*%-%s*{", "}" },
      syntax = yaml_bracket_list, type = "operator"
    },
    -- rule to optimize space handling
    { pattern = "%s+",                         type = "normal"   },
  --- all the other rules
    -- comments
    { pattern = { "#", "\n"},                  type = "comment"  },
    -- strings
    { pattern = { '"', '"', '\\' },            type = "string"   },
    { pattern = { "'", "'", '\\' },            type = "string"   },
    -- extra bracket lists rules on explicit type
    {
      pattern = { "!!%w+%s+%[", "%]"},
      syntax = yaml_bracket_list, type = "operator"
    },
    {
      pattern = { "!!%w+%s+{", "}"},
      syntax = yaml_bracket_list, type = "operator"
    },
    -- numeric place holders
    { pattern = "%-?%.inf",                    type = "number"   },
    { pattern = "%.NaN",                       type = "number"   },
    -- parent list element
    {
      pattern = "^%-()%s+()[%w%d]+%g+()%s*():()%s",
      type = { "operator", "normal", "keyword2", "normal", "operator", "normal" }
    },
    -- key label
    {
      pattern = "%&()%g+",
      type = { "keyword", "literal" }
    },
    -- key elements expansion
    { pattern = "<<",                          type = "literal"  },
    {
      pattern = "%*()[%w%d_]+",
      type = { "keyword", "literal" }
    },
    -- explicit data types
    { pattern = "!!%g+",                       type = "keyword"  },
    -- parent key
    {
      pattern = "^[%w%d]+%g+()%s*():()%s",
      type = { "literal", "normal", "operator", "normal" }
    },
    -- variables
    { pattern = "%$%a%w+",                     type = "keyword"  },
    { pattern = "%$%{%{.-%}%}",                type = "keyword"  },
    -- numbers
    { pattern = "[%+%-]?0%d+",                 type = "number"   },
    { pattern = "[%+%-]?0x%x+",                type = "number"   },
    { pattern = "[%+%-]?%d+[,%.eE:%+%d]*%d+",  type = "number"   },
    { pattern = "[%+%-]?%d+",                  type = "number"   },
    -- special operators
    { pattern = "[%*%|%!>%%]",                 type = "keyword"  },
    { pattern = "[%-%$:%?]+",                  type = "operator" },
    -- Everything else as a string
    { pattern = "[%d%a_][%g_]*",               type = "string"   },
    { pattern = "%p+",                         type = "string"   }
  },
  symbols = {
    ["true"]  = "number",
    ["false"] = "number",
    ["y"]     = "number",
    ["n"]     = "number"
  }
}
