--mod-version:3
local syntax = require 'core.syntax'

local label, sublabel = "function", "keyword2"

syntax.add {
	name = "Uxntal",
	files = { "%.tal$" },
	block_comment = { '(', ')' },
	patterns = {
		{ pattern = {'%(', '%)'},       type = "comment"  },
		{ pattern = "@%S*%s+%f[[]",     type = label      },
		{ pattern = "@%S+",             type = "string"   },
		{ pattern = "%u+()[2kr]*",      type = { "symbol", "keyword" } },
		{ pattern = "%%%S+",            type = "keyword"  },
		{ pattern = "&%S+",             type = sublabel   },
		{ pattern = "\"%S+",            type = "string"   },
		{ pattern = "%.%S+()/%S*",      type = { label, sublabel } },
		{ pattern = "%.%S+",            type = label      },
		{ pattern = "|%x+",             type = "string"   },
		{ pattern = "[.,;_=-]%S+",      type = sublabel   },
		{ pattern = "%$%d+",            type = "number"   },
		{ pattern = "#?%x%x%x%x%f[%X]", type = "number"   },
		{ pattern = "#?%x%x%f[%X]",     type = "number"   },
		{ pattern = "[!?]()[^%[%]{}%s]+", type = { "operator", "function" } },
		{ pattern = "[^%[%]{}%s]+",     type = "function" },
	},
	symbols = {
		-- no mode keywords
		["JCI"] = "keyword",
		["JMI"] = "keyword",
		["JSI"] = "keyword",
		["BRK"] = "keyword",

		-- lit only has 4 modes
		["LIT"]   = "keyword",

		-- the rest
		["EQU"] = "keyword",
		["LDZ"] = "keyword",
		["ADD"] = "keyword",
		["INC"] = "keyword",
		["NEQ"] = "keyword",
		["STZ"] = "keyword",
		["SUB"] = "keyword",
		["POP"] = "keyword",
		["GTH"] = "keyword",
		["LDR"] = "keyword",
		["MUL"] = "keyword",
		["NIP"] = "keyword",
		["LTH"] = "keyword",
		["STR"] = "keyword",
		["DIV"] = "keyword",
		["SWP"] = "keyword",
		["JMP"] = "keyword",
		["LDA"] = "keyword",
		["AND"] = "keyword",
		["ROT"] = "keyword",
		["JCN"] = "keyword",
		["STA"] = "keyword",
		["ORA"] = "keyword",
		["DUP"] = "keyword",
		["JSR"] = "keyword",
		["DEI"] = "keyword",
		["EOR"] = "keyword",
		["OVR"] = "keyword",
		["STH"] = "keyword",
		["DEO"] = "keyword",
		["SFT"] = "keyword",
	}}
