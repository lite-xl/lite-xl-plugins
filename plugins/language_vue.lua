-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

syntax.add {
  name = "vue",
  files = { "%.vue" },
  patterns = {
    {
      pattern = {
        "<%s*[tT][eE][mM][pP][lL][aA][tT][eE]>",
        "<%s*/[tT][eE][mM][pP][lL][aA][tT][eE]>"
      },
      syntax = ".html",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%s+[tT][yY][pP][eE]%s*=%s*" ..
          "['\"]%a+/[jJ][aA][vV][aA][sS][cC][rR][iI][pP][tT]['\"]%s*>",
        "<%s*/[sS][cC][rR][iI][pP][tT]>"
      },
      syntax = ".js",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%s*>",
        "<%s*/%s*[sS][cC][rR][iI][pP][tT]>"
      },
      syntax = ".js",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][tT][yY][lL][eE][^>]*>",
        "<%s*/%s*[sS][tT][yY][lL][eE]%s*>"
      },
      syntax = ".css",
      type = "function"
    }
  },
  symbols = {},
}
