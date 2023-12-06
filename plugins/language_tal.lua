--mod-version:3

local label, sublabel = "function", "keyword2"

require 'core.syntax'.add {
	name = "Uxntal",
	files = { "%.tal$" },
	block_comment = { '(', ')' },
	patterns = {
		{ pattern = { "%f[%(]%(%s", "%)" }, type = "comment"  },
		{ pattern = "@%S*%s+%f[[]",         type = label      },
		{ pattern = "@%S+",                 type = "string"   },
		{ pattern = "%%%S+",                type = "keyword"  },
		{ pattern = "&%S+",                 type = sublabel   },
		{ pattern = "\"%S+",                type = "string"   },
		{ pattern = "%.%S+()/%S*",          type = { label, sublabel } },
		{ pattern = "%.%S+",                type = label      },
		{ pattern = "|%x+",                 type = "string"   },
		{ pattern = "[.,;_=-]%S+",          type = sublabel   },
		{ pattern = "%$%d+",                type = "number"   },
		{ pattern = "DE[OI][2kr]*",         type = "symbol"   },
		{ pattern = "#?%x%x%x%x%f[%X]",     type = "number"   },
		{ pattern = "#?%x%x%f[%X]",         type = "number"   },
		{ pattern = "[!?]()[^%[%]{}%s]+",   type = { "operator", "function" } },
		{ pattern = "[^%[%]{}%s]+",         type = "function" },
	},
	symbols = {
		-- no mode keywords
		["JCI"] = "keyword",
		["JMI"] = "keyword",
		["JSI"] = "keyword",
		["BRK"] = "keyword",

		-- lit only has 4 modes
		["LIT"]   = "keyword",
		["LIT2"]  = "keyword",
		["LITr"]  = "keyword",
		["LIT2r"] = "keyword",

		-- the rest
		["EQU"] = "keyword", ["EQU2"] = "keyword", ["EQUk"] = "keyword", ["EQUr"] = "keyword", ["EQU2k"] = "keyword", ["EQUkr"] = "keyword", ["EQU2r"] = "keyword", ["EQU2kr"] = "keyword",
		["LDZ"] = "keyword", ["LDZ2"] = "keyword", ["LDZk"] = "keyword", ["LDZr"] = "keyword", ["LDZ2k"] = "keyword", ["LDZkr"] = "keyword", ["LDZ2r"] = "keyword", ["LDZ2kr"] = "keyword",
		["ADD"] = "keyword", ["ADD2"] = "keyword", ["ADDk"] = "keyword", ["ADDr"] = "keyword", ["ADD2k"] = "keyword", ["ADDkr"] = "keyword", ["ADD2r"] = "keyword", ["ADD2kr"] = "keyword",
		["INC"] = "keyword", ["INC2"] = "keyword", ["INCk"] = "keyword", ["INCr"] = "keyword", ["INC2k"] = "keyword", ["INCkr"] = "keyword", ["INC2r"] = "keyword", ["INC2kr"] = "keyword",
		["NEQ"] = "keyword", ["NEQ2"] = "keyword", ["NEQk"] = "keyword", ["NEQr"] = "keyword", ["NEQ2k"] = "keyword", ["NEQkr"] = "keyword", ["NEQ2r"] = "keyword", ["NEQ2kr"] = "keyword",
		["STZ"] = "keyword", ["STZ2"] = "keyword", ["STZk"] = "keyword", ["STZr"] = "keyword", ["STZ2k"] = "keyword", ["STZkr"] = "keyword", ["STZ2r"] = "keyword", ["STZ2kr"] = "keyword",
		["SUB"] = "keyword", ["SUB2"] = "keyword", ["SUBk"] = "keyword", ["SUBr"] = "keyword", ["SUB2k"] = "keyword", ["SUBkr"] = "keyword", ["SUB2r"] = "keyword", ["SUB2kr"] = "keyword",
		["POP"] = "keyword", ["POP2"] = "keyword", ["POPk"] = "keyword", ["POPr"] = "keyword", ["POP2k"] = "keyword", ["POPkr"] = "keyword", ["POP2r"] = "keyword", ["POP2kr"] = "keyword",
		["GTH"] = "keyword", ["GTH2"] = "keyword", ["GTHk"] = "keyword", ["GTHr"] = "keyword", ["GTH2k"] = "keyword", ["GTHkr"] = "keyword", ["GTH2r"] = "keyword", ["GTH2kr"] = "keyword",
		["LDR"] = "keyword", ["LDR2"] = "keyword", ["LDRk"] = "keyword", ["LDRr"] = "keyword", ["LDR2k"] = "keyword", ["LDRkr"] = "keyword", ["LDR2r"] = "keyword", ["LDR2kr"] = "keyword",
		["MUL"] = "keyword", ["MUL2"] = "keyword", ["MULk"] = "keyword", ["MULr"] = "keyword", ["MUL2k"] = "keyword", ["MULkr"] = "keyword", ["MUL2r"] = "keyword", ["MUL2kr"] = "keyword",
		["NIP"] = "keyword", ["NIP2"] = "keyword", ["NIPk"] = "keyword", ["NIPr"] = "keyword", ["NIP2k"] = "keyword", ["NIPkr"] = "keyword", ["NIP2r"] = "keyword", ["NIP2kr"] = "keyword",
		["LTH"] = "keyword", ["LTH2"] = "keyword", ["LTHk"] = "keyword", ["LTHr"] = "keyword", ["LTH2k"] = "keyword", ["LTHkr"] = "keyword", ["LTH2r"] = "keyword", ["LTH2kr"] = "keyword",
		["STR"] = "keyword", ["STR2"] = "keyword", ["STRk"] = "keyword", ["STRr"] = "keyword", ["STR2k"] = "keyword", ["STRkr"] = "keyword", ["STR2r"] = "keyword", ["STR2kr"] = "keyword",
		["DIV"] = "keyword", ["DIV2"] = "keyword", ["DIVk"] = "keyword", ["DIVr"] = "keyword", ["DIV2k"] = "keyword", ["DIVkr"] = "keyword", ["DIV2r"] = "keyword", ["DIV2kr"] = "keyword",
		["SWP"] = "keyword", ["SWP2"] = "keyword", ["SWPk"] = "keyword", ["SWPr"] = "keyword", ["SWP2k"] = "keyword", ["SWPkr"] = "keyword", ["SWP2r"] = "keyword", ["SWP2kr"] = "keyword",
		["JMP"] = "keyword", ["JMP2"] = "keyword", ["JMPk"] = "keyword", ["JMPr"] = "keyword", ["JMP2k"] = "keyword", ["JMPkr"] = "keyword", ["JMP2r"] = "keyword", ["JMP2kr"] = "keyword",
		["LDA"] = "keyword", ["LDA2"] = "keyword", ["LDAk"] = "keyword", ["LDAr"] = "keyword", ["LDA2k"] = "keyword", ["LDAkr"] = "keyword", ["LDA2r"] = "keyword", ["LDA2kr"] = "keyword",
		["AND"] = "keyword", ["AND2"] = "keyword", ["ANDk"] = "keyword", ["ANDr"] = "keyword", ["AND2k"] = "keyword", ["ANDkr"] = "keyword", ["AND2r"] = "keyword", ["AND2kr"] = "keyword",
		["ROT"] = "keyword", ["ROT2"] = "keyword", ["ROTk"] = "keyword", ["ROTr"] = "keyword", ["ROT2k"] = "keyword", ["ROTkr"] = "keyword", ["ROT2r"] = "keyword", ["ROT2kr"] = "keyword",
		["JCN"] = "keyword", ["JCN2"] = "keyword", ["JCNk"] = "keyword", ["JCNr"] = "keyword", ["JCN2k"] = "keyword", ["JCNkr"] = "keyword", ["JCN2r"] = "keyword", ["JCN2kr"] = "keyword",
		["STA"] = "keyword", ["STA2"] = "keyword", ["STAk"] = "keyword", ["STAr"] = "keyword", ["STA2k"] = "keyword", ["STAkr"] = "keyword", ["STA2r"] = "keyword", ["STA2kr"] = "keyword",
		["ORA"] = "keyword", ["ORA2"] = "keyword", ["ORAk"] = "keyword", ["ORAr"] = "keyword", ["ORA2k"] = "keyword", ["ORAkr"] = "keyword", ["ORA2r"] = "keyword", ["ORA2kr"] = "keyword",
		["DUP"] = "keyword", ["DUP2"] = "keyword", ["DUPk"] = "keyword", ["DUPr"] = "keyword", ["DUP2k"] = "keyword", ["DUPkr"] = "keyword", ["DUP2r"] = "keyword", ["DUP2kr"] = "keyword",
		["JSR"] = "keyword", ["JSR2"] = "keyword", ["JSRk"] = "keyword", ["JSRr"] = "keyword", ["JSR2k"] = "keyword", ["JSRkr"] = "keyword", ["JSR2r"] = "keyword", ["JSR2kr"] = "keyword",
		["DEI"] = "keyword", ["DEI2"] = "keyword", ["DEIk"] = "keyword", ["DEIr"] = "keyword", ["DEI2k"] = "keyword", ["DEIkr"] = "keyword", ["DEI2r"] = "keyword", ["DEI2kr"] = "keyword",
		["EOR"] = "keyword", ["EOR2"] = "keyword", ["EORk"] = "keyword", ["EORr"] = "keyword", ["EOR2k"] = "keyword", ["EORkr"] = "keyword", ["EOR2r"] = "keyword", ["EOR2kr"] = "keyword",
		["OVR"] = "keyword", ["OVR2"] = "keyword", ["OVRk"] = "keyword", ["OVRr"] = "keyword", ["OVR2k"] = "keyword", ["OVRkr"] = "keyword", ["OVR2r"] = "keyword", ["OVR2kr"] = "keyword",
		["STH"] = "keyword", ["STH2"] = "keyword", ["STHk"] = "keyword", ["STHr"] = "keyword", ["STH2k"] = "keyword", ["STHkr"] = "keyword", ["STH2r"] = "keyword", ["STH2kr"] = "keyword",
		["DEO"] = "keyword", ["DEO2"] = "keyword", ["DEOk"] = "keyword", ["DEOr"] = "keyword", ["DEO2k"] = "keyword", ["DEOkr"] = "keyword", ["DEO2r"] = "keyword", ["DEO2kr"] = "keyword",
		["SFT"] = "keyword", ["SFT2"] = "keyword", ["SFTk"] = "keyword", ["SFTr"] = "keyword", ["SFT2k"] = "keyword", ["SFTkr"] = "keyword", ["SFT2r"] = "keyword", ["SFT2kr"] = "keyword",
	}
}
