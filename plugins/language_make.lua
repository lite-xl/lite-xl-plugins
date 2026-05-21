-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Makefile",
  files = { PATHSEP .. "[Mm]akefile$", "%.mk$" },
  comment = "#",
  patterns = {
    { pattern = "#.*",                    type = "comment"  },
    { pattern = [[\.]],                   type = "normal"   },
    { pattern = "$[@^<%%?+|*]",           type = "keyword2" },
    { pattern = "$%(.-%)",                type = "symbol"   },
    { pattern = "%f[%w_][%d%.]+%f[^%w_]", type = "number"   },
    { regex = [[^\s*+[^:#=\s]+\s*+()(?::{1,3}|[?+!])?=]], type = { "literal", "operator" } },
    { regex = [[^\s*+\.[^:=]+\s*+()::?]], type = { "keyword2", "operator" } },
    { regex = [[^\s*+[^:=]+\s*+()::?]],   type = { "function", "operator" } },
    { pattern = "-?[^%s:#=+?!]+%f[%s]",   type = "normal" },
  },
  symbols = {
    ["define"] = "keyword",
    ["endef"] = "keyword",
    ["undefine"] = "keyword",
    ["ifdef"] = "keyword",
    ["ifndef"] = "keyword",
    ["ifeq"] = "keyword",
    ["ifneq"] = "keyword",
    ["else"] = "keyword",
    ["endif"] = "keyword",
    ["include"] = "keyword",
    ["-include"] = "keyword",
    ["sinclude"] = "keyword",
    ["override"] = "keyword",
    ["export"] = "keyword",
    ["unexport"] = "keyword",
    ["private"] = "keyword",
    ["vpath"] = "keyword",
  },
}
