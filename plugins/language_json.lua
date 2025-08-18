-- mod-version:3 priority:110

local syntax = require "core.syntax"

syntax.add {
  name = "JSON",
  
  files = { 
    "%.json$",
    "%.cjson$",
    "%.jsonc$",
    "%.ipynb$",
  },
  
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {
  
    -- cjson support
    { pattern = "//.*", type = "comment" },
    { pattern = { "/%*", "%*/" }, type = "comment" },
    
    { regex = [["(?:[^"\\]|\\.)*"()\s*:]], type = { "keyword", "normal" } }, -- key
    { regex = [["(?:[^"\\]|\\.)*"]], type = "string" }, -- value
    { pattern = "0x[%da-fA-F]+", type = "number" },
    { pattern = "-?%d+[%d%.eE]*",  type = "number" },
    { pattern = "-?%.?%d+", type = "number" },
    { pattern = "null", type = "literal" },
    { pattern = "true", type = "literal" },
    { pattern = "false", type = "literal" }
  },
  symbols = { }
}

