-- mod-version:3
local syntax = require "core.syntax"


local typst_math = {

	patterns = {

		{ pattern = { "/%*", "%*/" },              type = "comment"  },
		{ pattern = "//.*",                        type = "comment"  },

		{ pattern = { '"', '"', '\\' },            type = "string"   },
		{ pattern = "#%a+",                        type = "literal"  },
		{ pattern = "%a+%f[(]",                    type = "function" },
		{ pattern = "%a%a+",                       type = "function" },


		{ pattern = "0x[%dabcdef]+",               type = "number"   },
		{ pattern = "0b[01]+",                     type = "number"   },
		{ pattern = "0o[01234567]+",               type = "number"   },
		{ pattern = "%d+[.e]%d+",                  type = "number"   },
		{ pattern = "%d",                          type = "number"   },

		{ pattern = "&",                           type = "literal"  },
		{ pattern = "!=",                          type = "operator" },
		{ pattern = "[%+%-=/%*%^%%<>~|_^\\]",      type = "operator" },
		{ pattern = "%a%a+",                       type = "symbol"   },

	},

	symbols = {
		["alpha"]    = "keyword2",
		["beta"]     = "keyword2",
		["gamma"]    = "keyword2",
		["delta"]    = "keyword2",
		["epsilon"]  = "keyword2",
		["zeta"]     = "keyword2",
		["eta"]      = "keyword2",
		["theta"]    = "keyword2",
		["iota"]     = "keyword2",
		["kappa"]    = "keyword2",
		["lambda"]   = "keyword2",
		["mu"]       = "keyword2",
		["nu"]       = "keyword2",
		["xi"]       = "keyword2",
		["omicron"]  = "keyword2",
		["pi"]       = "keyword2",
		["rho"]      = "keyword2",
		["sigma"]    = "keyword2",
		["tau"]      = "keyword2",
		["upsilon"]  = "keyword2",
		["phi"]      = "keyword2",
		["chi"]      = "keyword2",
		["psi"]      = "keyword2",
		["omega"]    = "keyword2",

		["Alpha"]    = "keyword2",
		["Beta"]     = "keyword2",
		["Gamma"]    = "keyword2",
		["Delta"]    = "keyword2",
		["Epsilon"]  = "keyword2",
		["Zeta"]     = "keyword2",
		["Eta"]      = "keyword2",
		["Theta"]    = "keyword2",
		["Iota"]     = "keyword2",
		["Kappa"]    = "keyword2",
		["Lambda"]   = "keyword2",
		["Mu"]       = "keyword2",
		["Nu"]       = "keyword2",
		["Xi"]       = "keyword2",
		["Omicron"]  = "keyword2",
		["Pi"]       = "keyword2",
		["Rho"]      = "keyword2",
		["Sigma"]    = "keyword2",
		["Tau"]      = "keyword2",
		["Upsilon"]  = "keyword2",
		["Phi"]      = "keyword2",
		["Chi"]      = "keyword2",
		["Psi"]      = "keyword2",
		["Omega"]    = "keyword2",
	}
}

-- there was a bug where the string highlighting did not work properly
-- (probably becuase the tokenizer prioritizes subsyntaxes over clasic start-end patterns)
-- so in order to fix this issue, I had to create this extra sub-syntax.
local typst_string = {

	patterns = {
		{ pattern = "\\.",     type = "string" },
		{ pattern = '[^"\\]+', type = "string" }
	},

	symbols = {}
}


local typst_script = {

	patterns = {

		{ pattern = { "/%*", "%*/" },              type = "comment"                       },
		{ pattern = "//.*",                        type = "comment"                       },

		{ pattern = { '"', '"', '\\' },            type = "string", syntax = typst_string },
		{ pattern = {"%[", "%]"},                  type = "normal", syntax = ".typ"       },
		{ pattern = "[%a_][%w_%-]*%f[(]",          type = "function"                      },
		{ pattern = "[%+%-=/%*%^%%<>~|&_^\\]",     type = "operator"                      },
		{ pattern = "%f[^#][%a_]+",                type = "literal"                       },
		{ pattern = "#",                           type = "literal"                       },

		{ pattern = "0x[%dabcdef]+()%a*",          type = {"number", "keyword2"}          },
		{ pattern = "0b[01]+()%a*",                type = {"number", "keyword2"}          },
		{ pattern = "0o[01234567]+()%a*",          type = {"number", "keyword2"}          },
		{ pattern = "%d+[.e]%d+()%a*",             type = {"number", "keyword2"}          },
		{ pattern = "%d+()%a*",                    type = {"number", "keyword2"}          },

		{ pattern = "%a%a+",                       type = "symbol"                        },

	},


	symbols = {
		["set"]      = "keyword",
		["let"]      = "keyword",
		["show"]     = "keyword",
		["include"]  = "keyword",
		["import"]   = "keyword",
		["context"]  = "keyword",
		["if"]       = "keyword",
		["else"]     = "keyword",
		["for"]      = "keyword",
		["in"]       = "keyword",
		["while"]    = "keyword",
		["break"]    = "keyword",
		["continue"] = "keyword",
		["return"]   = "keyword",
		["as"]       = "keyword",
		["or"]       = "keyword",
		["and"]      = "keyword",
		["not"]      = "keyword",

		["true"]     = "literal",
		["false"]    = "literal",
	}
}

table.insert(typst_script.patterns, 1, { pattern = { "%(", "%)" }, syntax = typst_script })
table.insert(typst_script.patterns, 1, { pattern = { "{",  "}"  }, syntax = typst_script })



local typst_syntax = {
	name = "Typst",
	files = { "%.typ$" },
	comment = "//",
	block_comment = { "/*", "*/" },

	patterns = {
		{ pattern = { "%[", "%]" }, syntax = ".typ" },
		{
			pattern = { "#()import", "\n"    },
			type    = { "literal", "keyword" },
			syntax  = typst_script
		},
		{
			pattern = { "#()include", "\n"   },
			type    = { "literal", "keyword" },
			syntax  = typst_script
		},
		{
			pattern = { "#()set", "\n"       },
			type    = { "literal", "keyword" },
			syntax  = typst_script
		},
		{
			pattern = { "#()let", "\n"       },
			type    = { "literal", "keyword" },
			syntax  = typst_script
		},
		{
			pattern = { "#()show", "\n"      },
			type    = { "literal", "keyword" },
			syntax  = typst_script
		},
		{
			pattern = { "#()context", "\n"      },
			type    = { "literal", "keyword" },
			syntax  = typst_script
		},

		{ pattern = { "%f[#]", "%f[%s']"},      type = "literal", syntax = typst_script },
		{ pattern = { "%$", "%$", "\\" },       type = "literal", syntax = typst_math   },

		{ pattern = { "```js"  , "```", "\\" }, type = "string", syntax = ".js"         },
		{ pattern = { "```py",   "```", "\\" }, type = "string", syntax = ".py"         },
		{ pattern = { "```rust", "```", "\\" }, type = "string", syntax = ".rs"         },
		{ pattern = { "```c",    "```", "\\" }, type = "string", syntax = ".c"          },
		-- Possibility to add more syntax later
		{ pattern = { "`", "`", "\\" },         type = "string"                         },

		{ pattern = { "<", ">" },               type = "string"                         },
		{ pattern = { "@", "%s" },              type = "string"                         },

		{ pattern = "//.*",                     type = "comment"                        },
		{ pattern = { "/%*", "%*/" },           type = "comment"                        },

		--{ pattern = {"link"},                      type = "typst_underline"                }, -- add underline text later

		-- Finish later
		{ pattern = "^%s*=+%s.+%f[\n]",         type = "keyword"                        }, -- Bold
		{ pattern = {"%*_", "_%*"},             type = "keyword"                        }, -- Bold Italic
		{ pattern = {"_%*", "%*_"},             type = "keyword"                        }, -- Bold Italic
		{ pattern = {"_", "_"},                 type = "keyword"                        }, -- Italic
		{ pattern = {"%*", "%*"},               type = "keyword2"                       }, -- Bold

		{ pattern = "[%+%-\\/]",                type = "operator"                       },
		{ pattern = "\\[nrt]",                  type = "string"                         },
		{ pattern = "\\u%b{}",                  type = "string"                         },
		{ pattern = "\\.",                      type = "normal"                         },

	},

	symbols = {}
}





syntax.add(typst_syntax)
