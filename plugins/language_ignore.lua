-- mod-version:3

local syntax = require "core.syntax"
local style = require "core.style"
local common = require "core.common"

style.syntax["ignore"] = { common.color "#72B886" }
style.syntax["exclude"] = { common.color "#F36161" }

syntax.add {
  name = ".ignore file",
  files = { "%..*ignore$" },
  comment = "#",
  patterns = {
    { regex = "^ *#.*$",            type = "comment" },
    { regex = { "(?=^ *!.)", "$" }, type = "ignore"  },
    { regex = { "(?=.)", "$" },     type = "exclude" },
  },
  symbols = {}
}
