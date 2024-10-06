-- mod-version:3
local syntax = require "core.syntax"

-- Keywords
local keywords = {
  "enablehashcomments", "disablehashcomments", "call", "class", "from", "get", "give",
  "import", "load", "new", "package", "private", "changeringkeyword", "changeringoperator",
  "loadsyntax", "endclass", "endpackage", "if", "but", "else", "elseif", "ok", "for",
  "foreach", "to", "next", "catch", "step", "endfor", "while", "other", "end", "do",
  "endwhile", "endswitch", "endtry", "try", "break", "bye", "continue", "default",
  "endfunc", "endfunction", "return", "switch", "case", "on", "off", "again", "exit",
  "loop", "done", "in", "func", "def"
}

-- Types using ring type hints library
local types = {
  "char", "unsigned", "signed", "int", "short", "long", "float", "double", "void",
  "byte", "boolean", "string", "list", "number", "object", "public", "static",
  "abstract", "protected", "override"
}

-- Special values
local literals = {
  "true", "false", "null"
}

-- Built-in functions
local builtin_functions = {
  "nl", "see", "put", "print"
}

local symbols = {}

for _, keyword in ipairs(keywords) do
  symbols[keyword:upper()] = "keyword"
  symbols[keyword] = "keyword"
end

for _, type in ipairs(types) do
  symbols[type:upper()] = "keyword2"
  symbols[type] = "keyword2"
end

for _, literal in ipairs(literals) do
  symbols[literal:upper()] = "literal"
  symbols[literal] = "literal"
end

for _, func in ipairs(builtin_functions) do
  symbols[func:upper()] = "function"
  symbols[func] = "function"
end

syntax.add {
  name = "Ring",
  files = { "%.ring$", "%.rh$", "%.rform$" },
  comment = "//",
  patterns = {
    { pattern = "#.*",                  type = "comment"  },
    { pattern = "//.*",                 type = "comment"  },
    { pattern = { "/%*", "%*/" },       type = "comment"  },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = { "`", "`" },           type = "string"   },
    { pattern = "-?%d+[%d%.]*f?",       type = "number"   },
    { pattern = "-?0x%x+",              type = "number"   },
    { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
    { pattern = "[%a_][%w_]*",          type = "symbol"   },
    { pattern = ":%a+",                 type = "literal"  },
  },
  symbols = symbols
}
