-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "OpenSCAD",
  files = {"%.scad$"},
  comment = "//",
  block_comment = { "/*", "*/" },
  patterns = {
    { pattern = "//.*",                          type = "comment"  }, -- Single-line comment
    { pattern = { "/%*", "%*/" },                type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"', '\\' },              type = "string"   }, -- String, double quotes
    { pattern = { "'", "'", '\\' },              type = "string"   }, -- String, apices
    { pattern = "-?0x%x+",                       type = "number"   }, -- ?
    { pattern = "-?%d+[%d%.eE]*[a-zA-Z]?",       type = "number"   }, -- ?
    { pattern = "-?%.?%d+",                      type = "number"   }, -- ?
    { pattern = "[%+%-=/%*%^%%<>!~|&%?%:]",      type = "operator" }, -- Operators
    { pattern = "[%a_][%w_]*%f[(]",              type = "function" }, -- Functions
    { regex   = "\\$[a-zA-Z]+",                  type = "keyword"  }, -- Special variables
    { pattern = "[%a_][%w_]*",                   type = "symbol"   },
  },
  symbols = {
    -- ?
    ["var"]               = "keyword",
    ["module"]            = "keyword",
    ["function"]          = "keyword",
    ["include"]           = "keyword",
    ["use"]               = "keyword",
    -- Constants
    ["undef"]             = "keyword2",
    ["PI"]                = "keyword2",
    -- 2D
    ["circle"]            = "keyword",
    ["square"]            = "keyword",
    ["polygon"]           = "keyword",
    ["text"]              = "keyword",
    ["import"]            = "keyword",
    ["projection"]        = "keyword",
    -- 3D
    ["sphere"]            = "keyword",
    ["cube"]              = "keyword",
    ["cylinder"]          = "keyword",
    ["polyhedron"]        = "keyword",
    ["surface"]           = "keyword",
    -- Transformations
    ["linear_extrude"]    = "keyword",
    ["rotate_extrude"]    = "keyword",
    ["translate"]         = "keyword",
    ["rotate"]            = "keyword",
    ["scale"]             = "keyword",
    ["resize"]            = "keyword",
    ["mirror"]            = "keyword",
    ["multmatrix"]        = "keyword",
    ["color"]             = "keyword",
    ["offset"]            = "keyword",
    ["hull"]              = "keyword",
    ["minkowski"]         = "keyword",
    -- Boolean Operations
    ["union"]             = "keyword",
    ["difference"]        = "keyword",
    ["intersection"]      = "keyword",
    -- Flow Control
    ["for"]               = "keyword",
    ["each"]              = "keyword",
    -- Type Test Functions
    ["is_undef"]          = "function",
    ["is_bool"]           = "function",
    ["is_num"]            = "function",
    ["is_string"]         = "function",
    ["is_list"]           = "function",
    ["is_function"]       = "function",
    -- Other
    ["echo"]              = "keyword",
    ["render"]            = "keyword",
    ["children"]          = "keyword",
    ["assert"]            = "keyword",
    -- Functions
    ["concat"]            = "function",
    ["lookup"]            = "function",
    ["str"]               = "function",
    ["chr"]               = "function",
    ["ord"]               = "function",
    ["search"]            = "function",
    ["version"]           = "function",
    ["version_num"]       = "function",
    ["parent_module"]     = "function",    
    -- Math Functions
    ["abs"]               = "keyword",
    ["sign"]              = "keyword",
    ["sin"]               = "keyword",
    ["cos"]               = "keyword",
    ["tan"]               = "keyword",
    ["acos"]              = "keyword",
    ["asin"]              = "keyword",
    ["atan"]              = "keyword",
    ["atan2"]             = "keyword",
    ["floor"]             = "keyword",
    ["round"]             = "keyword",
    ["ceil"]              = "keyword",
    ["ln"]                = "keyword",
    ["len"]               = "keyword",
    ["let"]               = "keyword",
    ["log"]               = "keyword",
    ["pow"]               = "keyword",
    ["sqrt"]              = "keyword",
    ["exp"]               = "keyword",
    ["rands"]             = "keyword",
    ["min"]               = "keyword",
    ["max"]               = "keyword",
    ["norm"]              = "keyword",
    ["cross"]             = "keyword",
    -- Literals
    ["true"]              = "literal",
    ["false"]             = "literal",
  }
}
