--- Author: Rohan Vashisht: https://github.com/rohanvashisht1234/
-- mod-version:3
------------ IMPORT LIB ------------
local syntax_highlight = require("core.syntax")
------------------------------------

------------- DATABASE -------------

---- SYMBOLS ----
local SYMBOLS = {}

local KEYWORDS = {
  "break",
  "continue",
  "elif",
  "else",
  "for",
  "if",
  "pass",
  "return",
  "True",
  "False"
}

local KEYWORDS2 = {
  "as",
  "assert",
  "class",
  "del",
  "except",
  "finally",
  "from",
  "global",
  "import",
  "in",
  "is",
  "lambda",
  "nonlocal",
  "raise",
  "try",
  "while",
  "with",
  "yield"
}

local LITERALS = {
  "all",
  "any",
  "bool",
  "dict",
  "dir",
  "enumerate",
  "getattr",
  "hasattr",
  "hash",
  "int",
  "len",
  "list",
  "load",
  "max",
  "min",
  "repr",
  "reversed",
  "sorted",
  "str",
  "tuple",
  "type",
  "zip"
}
-----------------

---- PATTERNS ----
local PATTERNS = {
  { pattern = { '"', '"', '\\' }, type = "string"   },  -- tested ok
  { pattern = "#.*",              type = "comment"  },  -- tested ok
  { pattern = "[!%-/*?:=><]",     type = "operator" },  -- tested ok
  { pattern = "-?%d+[%d%.eE_]*",  type = "number"   },  -- tested ok
  { pattern = '[%a_][%w_]*%f[(]', type = 'function' },  -- tested ok
  { pattern = "-?%d+[%d%.eE_]*",  type = "number"   },  -- tested ok
  { pattern = "[%a_][%w_]*",      type = "normal"   }   -- tested ok
}
------------------
------------------------------------

--------------- MAIN ---------------
for _, keyword in ipairs(KEYWORDS) do
  SYMBOLS[keyword] = "keyword"
end
for _, keyword2 in ipairs(KEYWORDS2) do
  SYMBOLS[keyword2] = "keyword2"
end
for _, literal in ipairs(LITERALS) do
  SYMBOLS[literal] = "literal"
end
syntax_highlight.add {
  name = "Bazel",
  files = {"%.bazel$","%.bzl$"},
  comment = "#",
  patterns = PATTERNS,
  symbols = SYMBOLS,
}
------------------------------------
