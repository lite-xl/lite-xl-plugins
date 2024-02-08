-- mod-version:3
local syntax = require "core.syntax"
local style = require "core.style"

-- This syntax is probably very borken, so feel free to improve it.

--region add other styles
local new_styles = {"bold", "italic", "bold_italic", "underline"}

local code_font_size = style.code_font:get_size()
local code_font_path = style.code_font:get_path()

if type(code_font_path) == "table" then
    code_font_path = code_font_path[1]
end

for _, attr in pairs(new_styles) do
  local attributes = {}
  if attr ~= "bold_italic" then
    attributes[attr] = true
  else
    attributes["bold"] = true
    attributes["italic"] = true
  end
  -- yes way to copy user custom font with additional attributes :)
  style.syntax_fonts["typst_"..attr] = renderer.font.load(
    code_font_path,
    code_font_size,
    attributes
  )
end

--#endregion


syntax.add {
    name = "Typst_math",
    files = { "%.typmath$" }, --No file is actualy supposed to have this extension
    comment = "//",
    block_comment = { "/*", "*/" },

    patterns = {

        { pattern = { "/%*", "%*/" },              type = "comment" },
        { pattern = "//.*",                        type = "comment" },

        { pattern = { '"', '"', '\\' },            type = "string"  },

        { pattern = "[%a_][%w_%-]*%f[(]",          type = "function" },
        { pattern = "%a%a+",                       type = "function"},


        { pattern = "0x[%dabcdef]+",               type = "number" },
        { pattern = "0b[01]+",                     type = "number" },
        { pattern = "0o[01234567]+",               type = "number" },
        { pattern = "%d+[.e]%d+",                  type = "number" },
        { pattern = "%d",                          type = "number" },

        {pattern = "&",                            type = "literal"},
        { pattern = "[%+%-=/%*%^%%<>~|#_^]",       type = "operator" },

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
        ["Omega"]    = "keyword2"
    }
}


syntax.add {
    name = "Typst_header",
    files = { "%.typheader$" }, --No file is actualy supposed to have this extension
    comment = "//",
    block_comment = { "/*", "*/" },

    patterns = {

        { pattern = { "/%*", "%*/" },              type = "comment" },
        { pattern = "//.*",                        type = "comment" },

        { pattern = { '"', '"', '\\' },            type = "string"  },
        { pattern = {"%[", "%]"},                   type = "normal", syntax = ".typ" },

        { pattern = "[%a_][%w_%-]*%f[(]",          type = "function" },

        { pattern = "0x[%dabcdef]+",               type = "number" },
        { pattern = "0b[01]+",                     type = "number" },
        { pattern = "0o[01234567]+",               type = "number" },
        { pattern = "%d+[.e]%d+()[%a%%]+",         type = {"number", "keyword2"}},
        { pattern = "%d+[.e]%d+",                  type = "number" },
        { pattern = "%d+()[%a%%]+",                type = {"number", "keyword2"}},
        { pattern = "%d",                          type = "number" },


        { pattern = "[%+%-=/%*%^%%<>~|&#_^\\]",    type = "operator" },

    },


    symbols = {
        ["set"] = "keyword",
        ["let"] = "keyword",
        ["include"] = "keyword",
    }
}


syntax.add {
    name = "Typst",
    files = { "%.typ$" },
    comment = "//",
    block_comment = { "/*", "*/" },

    patterns = {



        { pattern = {"%$", "%$", "\\"},            type = "literal", syntax = ".typmath" },
        { pattern = {"```js", "```", "\\"},        type = "literal", syntax = ".js" },
        { pattern = {"#", "[^,%(%[{]\n"},                   type = "literal", syntax = ".typheader" },
        { pattern = {"`", "`", "\\"},              type = "normal"},

        { pattern = { '"', '"', '\\' },            type = "string"  },


        { pattern = "//.*",                        type = "comment" },
        { pattern = { "/%*", "%*/" },              type = "comment" },

   --     { pattern = {"link"},                    type = "typst_underline"}, -- add underline text later (keeps crashing)

        { pattern = "^=+ ().+%f[\n]",                type ={"operator", "typst_bold"}},

        { pattern = {"%*_", "_%*[%s,%.]"},     type = "typst_bold_italic"},
        { pattern = {"_%*", "%*_[%s,%.]"},     type = "typst_bold_italic"},
        { pattern = {"_", "_[%s,%.]"},         type = "typst_italic"},
        { pattern = {"%*[^%/]", "%*[%s,%.]"},  type = "typst_bold"},

        { pattern = "[%+%-\\]",    type = "operator" },


    },



    symbols = {

    }
}
