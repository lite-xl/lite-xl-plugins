local syntax = require "core.syntax"

-- csv basic syntax for lite <liqube>
syntax.add {
  files = { "%.csv$" },
  patterns = {
  { pattern = "-?%.?%d+f?",               type = "number"   },  -- numbers
  { pattern = "[,;|]",                    type = "operator" },  -- operators
  { pattern = { '"', '"', '\\' },         type = "string"   },  -- strings
  { pattern = { "'", "'", '\\' },         type = "string"   },  -- strings
  },
  symbols = { },
}
