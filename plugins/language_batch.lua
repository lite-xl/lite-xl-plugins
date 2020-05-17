local syntax = require "core.syntax"

-- liqube sat may 16, 2020
syntax.add {
  files = { "%.bat$", "%.cmd$" },
  comment = "rem",
  patterns = {
	{ pattern = "@echo off\n",					type = "keyword"  },
	{ pattern = "@echo on\n",					type = "keyword"  },
	{ pattern = "rem.-\n",						type = "comment"  },	-- rem comment line, rem, rem.
	{ pattern = "REM.-\n",						type = "comment"  },
	{ pattern = "%:%:.-\n",						type = "comment"  },	-- :: comment line
	{ pattern = "%%%w+%%",						type = "symbol"	  },	-- %variable%
	{ pattern = "%%%%?~?[%w:]+",				type = "symbol"	  },	-- %1, %~dpn1, %~1:2, %%i, %%~i
	{ pattern = "[!=()%>&%^/\\]",				type = "operator" },	-- operators
	{ pattern = "-?%.?%d+f?",					type = "number"	  },	-- integer numbers
	{ pattern = { '"', '"', '\\' },				type = "string"	  },	-- "strings"
	{ pattern = "[%a_][%w_]*",					type = "normal"	  },
	{ pattern = ":eof",							type = "keyword"  },	-- todo: end processing here (lite cannot do that yet)
	{ pattern = "%s*:%w+",						type = "symbol"	  },	-- :labels
  },
  -- todo: caseless matching (lite cannot do that yet)
  symbols = {
	["if"]     		 = "keyword",
    ["else"]     	 = "keyword",
    ["elsif"]     	 = "keyword",
    ["not"]    		 = "keyword",
	["for"]    		 = "keyword",
	["do"]     		 = "keyword",
	["exist"]        = "keyword",
	["in"]           = "keyword",
	["equ"]          = "keyword", -- ==
	["neq"]          = "keyword", -- !=
	["lss"]          = "keyword", -- <
	["leq"]          = "keyword", -- <=
	["gtr"]          = "keyword", -- >
	["geq"]          = "keyword", -- >=
	["nul"]    		 = "keyword",
	["con"]    		 = "keyword",
	["prn"]    		 = "keyword",
	["prn"]    		 = "keyword",
	["lpt1"]     	 = "keyword",
	["com1"]    	 = "keyword",
	["com2"]    	 = "keyword",
	["com3"]    	 = "keyword",
	["com4"]    	 = "keyword",
	["errorlevel"]   = "keyword",
	["defined"]      = "keyword",
	["cmdextversion"]= "keyword",
	["goto"]   		 = "keyword",
    ["call"]   		 = "keyword",
	["verify"]       = "keyword",
	["setlocal"]     = "function",
	["endlocal"]     = "function",
	["enabledelayedexpansion"] = "function",
    ["set"]   		 = "function",
    ["echo"]   		 = "function",
    ["rd"]   		 = "function",
    ["xcopy"]   	 = "function",
    ["del"]    		 = "function",
    ["ren"]    		 = "function",
    ["rmdir"]  		 = "function",
    ["move"]   		 = "function",
	["copy"]   		 = "function",
	["find"]   		 = "function",
	["exit"]   		 = "function",
	["pause"]     	 = "function",
	["choice"]     	 = "function",
	["command"]      = "function",
	["cmd"]          = "function",
	["shift"]        = "function",
	["attrib"]       = "function",
	["type"]         = "function",
	["sort"]         = "function",
	["cd"]           = "function",
	["chdir"]        = "function",
	["md"]           = "function",
	["mkdir"]        = "function",
	["forfiles"]  	 = "function",
  },
}
