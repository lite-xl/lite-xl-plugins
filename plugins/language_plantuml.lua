-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax Reference
-- https://plantuml.com/

syntax.add {
  name = "PlantUML",
  files = { "%.puml$", "%.plantuml$", "%.pu$", "%.iuml$", "%.wsd$" },
  comment = "/'",
  block_comment = { "/'", "'/" },
  patterns = {
    { pattern = "^%'.*$",                                              type = "comment"  }, -- Single-line comment
    { pattern = { "^/'", "%'%/" } ,                                    type = "comment"  }, -- Multi-line comment
    { pattern = { '"', '"' },                                          type = "string"   }, -- String
    { pattern = "^%@%w+",                                              type = "keyword2" }, -- start... end...
    { pattern = "%-+%|?%>*",                                           type = "operator" }, -- Arrow operator
    { pattern = "%<?%|?%-+%*?",                                        type = "operator" }, -- Arrow operator
    { pattern = "%.+%|?%>?",                                           type = "operator" }, -- Arrow operator
    { pattern = "%<?%|?%.+",                                           type = "operator" }, -- Arrow operator
    { pattern = "[%*ox$#$}%+%^]%-+",                                   type = "operator" }, -- Arrow operator
    { pattern = "%<%<%w+%>%>",                                         type = "keyword2" }, -- Key
    -- FIX: mustn't extend beyond eventual parenthesis
    { pattern = "%:%s*.+$",                                            type = "keyword2" }, -- Attribute/Comment
    { pattern = "^%!.+",                                               type = "keyword2" }, -- ?
    -- TODO: type
    -- TODO: accessibility modifiers
    { pattern = "^%(%s*%)",                                            type = "keyword" }, -- Abbreviations
    { pattern = "^%<%s*%>",                                            type = "keyword" }, -- Abbreviations
    { pattern = "[%a_][%w_]*",                                         type = "symbol"   }, -- Everything else
  },
  symbols = {
    -- Literals
    ["true"] = "literal",
    ["false"] = "literal",
    -- Keywords
    ["abstract"] = "keyword",
    ["abstract class"] = "keyword",
    ["annotation"] = "keyword",
    ["circle"] = "keyword",
    ["class"] = "keyword",
    ["diamond"] = "keyword",
    ["entity"] = "keyword",
    ["enum"] = "keyword",
    ["exception"] = "keyword",
    ["interface"] = "keyword",
    ["metaclass"] = "keyword",
    ["protocol"] = "keyword",
    ["stereotype"] = "keyword",
    ["struct"] = "keyword",
    ["as"] = "keyword",
    ["package"] = "keyword",
    ["remove"] = "keyword",
    ["note"] = "keyword",
    ["end"] = "keyword",
    -- ?
    ["to"] = "keyword2",
    ["left"] = "keyword2",
    ["right"] = "keyword2",
    ["top"] = "keyword2",
    ["bottom"] = "keyword2",
    ["direction"] = "keyword2",
    ["of"] = "keyword2",
    ["set"] = "keyword2",
    ["separator"] = "keyword2",
    ["none"] = "keyword2",
  }
}
