-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Haxe Compiler Arguments",
  files = "%.hxml$",
  comment = "#",
  patterns = {
    { pattern = "#.*",             type = "comment"},
    { pattern = "%-[%-%w_]*",      type="keyword"},
    { pattern = "%.()%u[%w_]*",    type = {"normal", "keyword2"}},
  },
  symbols = {}
}

syntax.add {
  name = "Haxe String Interpolation",
  files = "%.hx__string_interp$",
  patterns = {
    { pattern = {"%${", "}", "\\"},     type="keyword", syntax = ".hx" },
    { pattern = {"%$", "%s", "\\"},     type="keyword", syntax = ".hx" },
    { pattern = "[^ ]",                 type = "string"}
  },
  symbols = {}
}

syntax.add {
  name = "Haxe Regular Expressions",
  files = "%.hx__regex$",
  patterns = {
    { pattern = "[%[%]%(%)]",           type = "string" },
    { pattern = "[%.%*%+%?%^%$%|%-]",   type = "operator" },
  },
  symbols = {}
}

syntax.add {
  name = "Haxe",
  files = "%.hx$",
  comment = "//",
  patterns = {
    { pattern = {"%~%/", "%/[igmsu]*"},                     type = "keyword2", syntax = ".hx__regex" },
    { pattern = "%.%.%.",                                   type = "operator" },
    { pattern = "%<()%u[%w_]*()%>*",                        type = {"operator", "keyword2", "operator"}},
    { pattern = "%#%s*[%a_]*().*\n",                        type = {"keyword", "normal"}   },
    { pattern = "import%s+()%u[%w]*",                       type = {"keyword", "keyword2"}},
    { pattern = "import%s+()[%w%.]*%.()%u[%w]*",            type = {"keyword", "normal", "keyword2"}},
    { pattern = "abstract%s+()%u[%w_]*%s*%(()%s*%u[%w_]*",  type = {"keyword2", "normal", "keyword2"} },
    { pattern = "from%s+()%u[%w_]*%s+()to%s+()%u[%w_]*",    type = {"keyword", "keyword2", "keyword", "keyword2"}},
    { pattern = "//.*\n",                                   type = "comment"  },
    { pattern = { "/%*", "%*/" },                           type = "comment"  },
    { pattern = { '"', '"', '\\' },                         type = "string"   },
    { pattern = { "'", "'", "\\" },                         type = "string", syntax = ".hx__string_interp"},  
    { pattern = "-?%.?%d+",                                 type = "number"   },
    { pattern = "-?0x%x+",                                  type = "number"   },
    { pattern = "-?%d+%.[%deE]+",                           type = "number"   },
    { pattern = "-?%d+[%deE]+",                             type = "number"   },
    { pattern = "[%+%-%.=/%*%^%%<>!~|&]",                   type = "operator" },
    { pattern = "[%a_][%w_]*()%s*%f[(]",                    type = {"function", "normal"} },
    { pattern = "[%a_][%w_]*",                              type = "symbol"   },
    { pattern = ":()%u[%a_][%w_]*",                         type = {"normal", "keyword2"}},
    { pattern = "@:[%a_][%w_]*%f[(]",                       type = "keyword"   },
    { pattern = "%$type",                                   type = "keyword"   },
  },
  symbols = {
    ["abstract"]   = "keyword2",
    ["extends"]    = "keyword2",
    ["typedef"]    = "keyword2",
    ["implements"] = "keyword2",
    ["import"]     = "keyword",
    ["package"]    = "keyword",
    ["using"]      = "keyword2",
    ["macro"]      = "keyword2",
    ["class"]      = "keyword",
    ["function"]   = "keyword2",
    ["var"]        = "keyword2",
    ["extern"]     = "keyword2",
    ["in"]         = "keyword",
    ["cast"]       = "keyword",
    ["get"]        = "keyword",
    ["set"]        = "keyword",
    ["never"]      = "keyword",
    ["inline"]     = "keyword",
    ["trace"]      = "keyword",
    ["final"]      = "keyword",
    ["break"]      = "keyword",
    ["case"]       = "keyword",
    ["catch"]      = "keyword",
    ["continue"]   = "keyword",
    ["default"]    = "keyword",
    ["do"]         = "keyword",
    ["else"]       = "keyword",
    ["enum"]       = "keyword",
    ["for"]        = "keyword",
    ["if"]         = "keyword",
    ["interface"]  = "keyword",
    ["new"]        = "keyword",
    ["override"]   = "keyword",
    ["private"]    = "keyword",
    ["public"]     = "keyword",
    ["return"]     = "keyword",
    ["static"]     = "keyword",
    ["switch"]     = "keyword",
    ["this"]       = "keyword",
    ["throw"]      = "keyword",
    ["try"]        = "keyword",
    ["while"]      = "keyword",
    ["true"]       = "literal",
    ["false"]      = "literal",
    ["null"]       = "literal",
  },
}

