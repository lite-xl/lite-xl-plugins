-- mod-version:3
local syntax = require 'core.syntax'

syntax.add {
	name = "Lox",
	files = { "%.lox$" },
	comment = "//",
	patterns = {
		{ pattern = "//.-\n",              type = "comment"  },
		{ pattern = { '"', '"' },          type = "string"   },
		{ pattern = "%a[%w_]*()%s*%f[(]",  type = {"function", "normal"} },
		{ pattern = "[%a_][%w_]*%s*%f[(]", type = "function" },
		{ pattern = "%d+%.?%d*",           type = "number"   },
		{ pattern = "%a%w*",               type = "symbol"   },
	},
	symbols = {
		["and"]    = "keyword",
		["class"]  = "keyword",
		["else"]   = "keyword",
		["false"]  = "literal",
		["for"]    = "keyword",
		["fun"]    = "keyword",
		["if"]     = "keyword",
		["nil"]    = "literal",
		["or"]     = "keyword",
		["print"]  = "keyword",
		["return"] = "keyword",
		["super"]  = "keyword2",
		["this"]   = "keyword2",
		["true"]   = "keyword",
		["var"]    = "keyword",
		["while"]  = "keyword",
	},
}
