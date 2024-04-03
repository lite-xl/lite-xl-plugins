-- mod-version:3

-- https://openscad.org/cheatsheet/index.html

local syntax = require "core.syntax"

syntax.add {
  name = "OpenSCAD",
  files = {"%.scad$"},
  comment = "//",
  patterns = {
    --{ pattern = "",                          type = "" },
    { pattern = "[%+%-=/%*%^%%<>!~|&]",      type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
  },
  symbols = {    
    ["cube"] = "function",
    ["cylinder"] = "function",
    ["import"] = "function",
    ["linear_extrude"] = "function",
    ["polyhedron"] = "function",
    ["rotate_extrude"] = "function",
    ["sphere"] = "function",
    ["surface"] = "function",

    ["color"] = "function",
    ["hull"] = "function",
    ["mirror"] = "function",
    ["minkowski"] = "function",
    ["multmatrix"] = "function",
    ["offset"] = "function",
    ["resize"] = "function",
    ["rotate"] = "function",
    ["scale"] = "function",
    ["translate"] = "function",

    ["abs"] = "function",
    ["sign"] = "function",
    ["sin"] = "function",
    ["cos"] = "function",
    ["tan"] = "function",
    ["acos"] = "function",
    ["asin"] = "function",
    ["atan"] = "function",
    ["atan2"] = "function",
    ["floor"] = "function",
    ["round"] = "function",
    ["ceil"] = "function",
    ["ln"] = "function",
    ["len"] = "function",
    ["let"] = "function",
    ["log"] = "function",
    ["pow"] = "function",
    ["sqrt"] = "function",
    ["exp"] = "function",
    ["rands"] = "function",
    ["min"] = "function",
    ["max"] = "function",
    ["norm"] = "function",
    ["cross"] = "function",

    [""] = "function",
    [""] = "function",
    [""] = "function",
    [""] = "function",
    [""] = "function",
    [""] = "function",
  }
}
