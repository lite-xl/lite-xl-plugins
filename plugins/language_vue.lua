-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

syntax.add {
  name = "Vue Component",
  files = { "%.vue$" },
  patterns = {
    {
      pattern = {
        "<%s*[tT][eE][mM][pP][lL][aA][tT][eE]%s*.*>",
        "<%s*/%s*[tT][eE][mM][pP][lL][aA][tT][eE]>"
      },
      syntax = ".html",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%s*.*%s+[lL][aA][nN][gG]=[\"']ts[\"']%s*.*>",
        "<%s*/%s*[sS][cC][rR][iI][pP][tT]>"
      },
      syntax = ".ts",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%s*.*>",
        "<%s*/%s*[sS][cC][rR][iI][pP][tT]>"
      },
      syntax = ".js",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][tT][yY][lL][eE]%s*.*%s+[lL][aA][nN][gG]=[\"']scss[\"']%s*.*>",
        "<%s*/%s*[sS][tT][yY][lL][eE]%s*>"
      },
      syntax = ".scss",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][tT][yY][lL][eE]%s*.*%s+[lL][aA][nN][gG]=[\"']sass[\"']%s*.*>",
        "<%s*/%s*[sS][tT][yY][lL][eE]%s*>"
      },
      syntax = ".sass",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][tT][yY][lL][eE]%s*.*>",
        "<%s*/%s*[sS][tT][yY][lL][eE]%s*>"
      },
      syntax = ".css",
      type = "function"
    },
  },
  symbols = {},
}
