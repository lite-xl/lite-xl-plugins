-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "AutoIT",
  files = { "%.au3$" },
  comment = ";",
  patterns = {
    -- Comentários de linha única
    { pattern = ";.*", type = "comment" },

    -- Comentários em bloco
    { pattern = { "#cs%*", "%*#ce" }, type = "comment" },
    { pattern = { "#comments-start%*", "%*#comments-end" },                                              type = "comment" },

    -- Variáveis (começam com $)
    { pattern = "%$[%w_]+", type = "keyword2" },

    -- Macros (começam com @)
    { pattern = "@[%w_]+", type = "number" },

    -- Números (Hexadecimais e Decimais)
    { pattern = "0[xX][%da-fA-F]+", type = "number" },
    { pattern = "%d+%.?%d*", type = "number" },
    { pattern = "%.%d+", type = "number" },

    -- Strings
    { pattern = { '"', '"' }, type = "string"  },
    { pattern = { "'", "'" }, type = "string"  },

    -- Include
    { pattern = "#include%s*", type = "keyword" },
    { pattern = "<[^>\n]+>",    type = "string" },

    -- Function
    -- { pattern = "[%a_][%w_]*()%s+()[%a_][%w_]*%f[%(]",
    --   type = { "literal", "normal", "function" }
    -- },
    -- { pattern = "[%a_][%w_]*%f[(]", type = "function" },

    -- Operadores e delimitadores
    -- { pattern = "[-+/*=<>%&^~]", type = "function" },
    { pattern = "[%(%)%&]", type = "function" },
  },
  symbols = {
    ["If"]          = "keyword",
    ["Then"]        = "keyword",
    ["Else"]        = "keyword",
    ["ElseIf"]      = "keyword",
    ["EndIf"]       = "keyword",
    ["Switch"]      = "keyword",
    ["Case"]        = "keyword",
    ["EndSwitch"]   = "keyword",
    ["Select"]      = "keyword",
    ["EndSelect"]   = "keyword",
    ["For"]         = "keyword",
    ["To"]          = "keyword",
    ["Step"]        = "keyword",
    ["Next"]        = "keyword",
    ["In"]          = "keyword",
    ["While"]       = "keyword",
    ["Wend"]        = "keyword",
    ["Do"]          = "keyword",
    ["Until"]       = "keyword",
    ["Func"]        = "keyword",
    ["EndFunc"]     = "keyword",
    ["Return"]      = "keyword",
    ["Exit"]        = "keyword",
    ["Global"]      = "keyword",
    ["Local"]       = "keyword",
    ["Const"]       = "keyword",
    ["Dim"]         = "keyword",
    ["Redim"]       = "keyword",
    ["And"]         = "function",
    ["Or"]          = "function",
    ["Not"]         = "function",
  },
}
