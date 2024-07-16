-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "D",
  files = { "%.d$", "%.di$" },
  comment = "//",
  patterns = {
    { pattern = "//.-\n",               type = "comment"  },
    { pattern = { "/%*", "%*/" },       type = "comment"  },
    { pattern = { "/%+", "%+/" },       type = "comment"  },
    { pattern = { '`', '`', '\\' },     type = "string"   },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = "-?0x[%x_]+",           type = "number"   },
    { pattern = "-?[%d_]+[%d%.eE]*f?",  type = "number"   },
    { pattern = "-?%.?%d+f?",           type = "number"   },
    { pattern = "[%+%-=/%*%^%%<>!~|&%$]+", type = "operator" },
    { pattern = "[%a_][%w_]*!?()[%(.]",        type = {"function", "normal"} }, -- highlight templates
    { pattern = "@safe",               type = "keyword"   },
    { pattern = "@trusted",            type = "keyword"   },
    { pattern = "@nogc",               type = "keyword"   },
  },
  symbols = {
    ["abstract"] = "keyword",
    ["alias"] = "keyword",
    ["align"] = "keyword",
    ["asm"] = "keyword",
    ["assert"] = "keyword",
    ["auto"] = "keyword",
    ["body"] = "keyword",
    ["bool"] = "keyword2",
    ["break"] = "keyword",
    ["byte"] = "keyword2",
    ["case"] = "keyword",
    ["cast"] = "keyword",
    ["catch"] = "keyword",
    ["cdouble"] = "keyword2",
    ["cent"] = "keyword2",
    ["cfloat"] = "keyword2",
    ["char"] = "keyword2",
    ["class"] = "keyword",
    ["const"] = "keyword",
    ["continue"] = "keyword",
    ["creal"] = "keyword2",
    ["dchar"] = "keyword2",
    ["debug"] = "keyword",
    ["default"] = "keyword",
    ["delegate"] = "keyword",
    ["deprecated"] = "keyword",
    ["do"] = "keyword",
    ["double"] = "keyword2",
    ["else"] = "keyword",
    ["enum"] = "keyword",
    ["export"] = "keyword",
    ["extern"] = "keyword",
    ["false"] = "literal",
    ["final"] = "keyword",
    ["finally"] = "keyword",
    ["float"] = "keyword2",
    ["for"] = "keyword",
    ["foreach"] = "keyword",
    ["foreach_reverse"] = "keyword",
    ["function"] = "keyword",
    ["goto"] = "keyword",
    ["idouble"] = "keyword2",
    ["if"] = "keyword",
    ["ifloat"] = "keyword2",
    ["immutable"] = "keyword",
    ["import"] = "keyword",
    ["in"] = "keyword",
    ["inout"] = "keyword",
    ["int"] = "keyword2",
    ["interface"] = "keyword",
    ["invariant"] = "keyword",
    ["ireal"] = "keyword2",
    ["is"] = "keyword",
    ["lazy"] = "keyword",
    ["long"] = "keyword2",
    ["macro"] = "keyword",
    ["mixin"] = "keyword",
    ["module"] = "keyword",
    ["new"] = "keyword",
    ["nothrow"] = "keyword",
    ["null"] = "literal",
    ["out"] = "keyword",
    ["override"] = "keyword",
    ["package"] = "keyword",
    ["pragma"] = "keyword",
    ["private"] = "keyword",
    ["protected"] = "keyword",
    ["public"] = "keyword",
    ["pure"] = "keyword",
    ["real"] = "keyword2",
    ["ref"] = "keyword",
    ["return"] = "keyword",
    ["scope"] = "keyword",
    ["shared"] = "keyword",
    ["short"] = "keyword2",
    ["static"] = "keyword",
    ["struct"] = "keyword",
    ["super"] = "keyword",
    ["switch"] = "keyword",
    ["synchronized"] = "keyword",
    ["template"] = "keyword",
    ["this"] = "keyword",
    ["throw"] = "keyword",
    ["true"] = "literal",
    ["try"] = "keyword",
    ["typeid"] = "keyword",
    ["typeof"] = "keyword",
    ["ubyte"] = "keyword2",
    ["ucent"] = "keyword2",
    ["uint"] = "keyword2",
    ["ulong"] = "keyword2",
    ["union"] = "keyword",
    ["unittest"] = "keyword",
    ["ushort"] = "keyword2",
    ["version"] = "keyword",
    ["void"] = "keyword",
    ["wchar"] = "keyword2",
    ["while"] = "keyword",
    ["with"] = "keyword",
    ["__FILE__"] = "keyword",
    ["__FILE_FULL_PATH__"] = "keyword",
    ["__MODULE__"] = "keyword",
    ["__LINE__"] = "keyword",
    ["__FUNCTION__"] = "keyword",
    ["__PRETTY_FUNCTION__"] = "keyword",
    ["__gshared"] = "keyword",
    ["__traits"] = "keyword",
    ["__vector"] = "keyword",
    ["__parameters"] = "keyword",
  },
}
