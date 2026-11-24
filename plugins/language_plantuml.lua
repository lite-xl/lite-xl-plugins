-- mod-version:3
local syntax = require "core.syntax"

-- Language Syntax Reference
-- https://plantuml.com/

-- WIP: class
-- TODO: usecase
-- TODO: sequence
-- TODO: activity
-- TODO: component
-- TODO: state
-- TODO: object
-- TODO: deployment
-- TODO: timing
-- TODO: ER

-- FUTURE_TODO: regex
-- FUTURE_TODO: wireframe
-- FUTURE_TODO: archimate
-- FUTURE_TODO: gantt
-- FUTURE_TODO: chronology
-- FUTURE_TODO: mindmap
-- FUTURE_TODO: WBS
-- FUTURE_TODO: EBNF
-- FUTURE_TODO: JSON
-- FUTURE_TODO: YAML

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
    { regex   = [[\-+(?>left)|(?>right)|(?>up)|(?>down)\-+\>]],        type = "operator" }, -- Arrow operator
    { regex   = [[\-+(?>l)|(?>r)\-+\>]],                               type = "operator" }, -- Arrow operator
    { pattern = "%<%<%w+%>%>",                                         type = "keyword2" }, -- Key
    -- FIX: the "::" completely messes up the attr/comment and the string patterns
    { regex   = [[\:\s*.+(?=\)|\]|\})]],                               type = "keyword2" }, -- Attribute/Comment/Type
    { pattern = "^%!.+",                                               type = "keyword2" }, -- ?
    { pattern = "[%-%#%~%+]",                                          type = "operator" }, -- Accessibility modifiers
    { pattern = "^%(%s*%)",                                            type = "keyword"  }, -- Abbreviations
    { pattern = "^%<%s*%>",                                            type = "keyword"  }, -- Abbreviations
    { pattern = "[%a_][%w_]*",                                         type = "symbol"   }, -- Everything else
    -- FIX: dots in es: "package A.B.C.D {" should be normal, not operator
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
    ["object"] = "keyword",
    ["json"] = "keyword",
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
