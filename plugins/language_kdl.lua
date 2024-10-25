-- mod-version:3
local syntax = require "core.syntax"

local identifier = "\"?[^%d%s\\/%(%){}<>;%[%]=,\"][^%s\\/%(%){}<>;%[%]=,\"]*\"?"

syntax.add {
  name = "KDL",
  files = { "%.kdl" },
  space_handling = false,
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {
    {
		pattern = "^%s*".. identifier .."%s*",
		type = "keyword"
	},--
    { pattern = "%s+",                      type = "normal"   },
    {
		pattern = "[{;]%s*()" .. identifier .. "%s*",
		type = {"normal", "keyword"}
	},--
    { pattern = { "r#+\"", "\"#+" },         type = "string"   },
    { pattern = { '"', '"', '\\' },          type = "string"   },
    { pattern = "[%-+]?0x[%x_]+",            type = "number"   },
    { pattern = "[%-+]?0b[01_]+",            type = "number"   },
    { pattern = "[%-+]?0o[0-7_]+",           type = "number"   },
    {
		pattern = "[%-+]?[%d_]+%.[%d_]+e[%-+]?[%d_]+",
		type = "number"
	},
	{ pattern = "[%-+]?[%d_]+%.[%d_]+",      type = "number"   },
    { pattern = "[%-+]?[%d_]+e[%-+]?[%d_]+", type = "number"   },
    { pattern = "[%-+]?[%d_]+",              type = "number"   },
    { pattern = "/[%-/].-\n",                type = "comment"  },
    { pattern = {"/%*", "%*/"},              type = "comment"  },
    { pattern = identifier,                  type = "keyword2" },
	{
		pattern = "%(()" .. identifier .. "()%)",
		type = {"normal", "function", "normal"}
	},
  },
  symbols = {
  	["null"]  = "literal",
  	["true"]  = "literal",
  	["false"] = "literal",
  	["i8"]    = "function",
  	["i32"]   = "function",
  	["i16"]   = "function",
  	["i64"]   = "function",
  	["u8"]    = "function",
  	["u32"]   = "function",
  	["u16"]   = "function",
  	["u64"]   = "function",
  	["isize"]   = "function",
  	["usize"]   = "function",
  	["f32"]   = "function",
  	["f64"]   = "function",
  	["decimal64"]   = "function",
  	["decimal128"]   = "function",
  	["date-time"]   = "function",
  	["time"]   = "function",
  	["date"]   = "function",
  	["duration"]   = "function",
  	["decimal"]   = "function",
  	["currency"]   = "function",
  	["country-2"]   = "function",
  	["country-3"]   = "function",
  	["country-subdivision"]   = "function",
  	["email"]   = "function",
  	["idn-email"]   = "function",
  	["hostname"]   = "function",
  	["idn-hostname"]   = "function",
  	["ipv4"]   = "function",
  	["ipv6"]   = "function",
  	["url"]   = "function",
  	["url-reference"]   = "function",
  	["irl"]   = "function",
  	["irl-reference"]   = "function",
  	["url-template"]   = "function",
  	["uuid"]   = "function",
  	["regex"]   = "function",
  	["base64"]   = "function",
  },
}
