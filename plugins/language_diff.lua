-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"
local style = require "core.style"
local common = require "core.common"

-- we need these symbol types to have uniform colors
style.syntax["diff_add"] = { common.color "#72b886" }
style.syntax["diff_del"] = { common.color "#F36161" }

syntax.add {
  name = "Diff",
  files = { "%.diff$", "%.patch$", "%.rej$" },
  headers = "^diff ",
  patterns = {
    -- Method the patch was generated with and source/target files
    { regex = "^diff .+\n$",                 type = "function" },
    -- Seen for changing the file permissions
    { regex = "^new .+\n$",                  type = "comment"  },
    -- Usually holds starting and ending commit
    { regex = "^index .+\n$",                type = "comment"  },
    -- Position to patch
    {
      pattern = "@@.-@@ ().+\n",            --with heading
      type = { "number", "string" }
    },
    {
      regex = "^@@ [\\d,\\-\\+ ]+ @@\n$",   --wihtout heading
      type = "number"
    },
    -- Other position to patch formats
    {
      regex = "^\\-{3} [\\d]+,[\\d]+ \\-{4}\n$",
      type = "number"
    },
    {
      regex = "^\\*{3} [\\d]+,[\\d]+ \\*{4}\n$",
      type = "number"
    },
    -- Source and target file
    { regex = "^-{3} .+\n$",                 type = "keyword"  },
    { regex = "^\\+{3} .+\n$",               type = "keyword"  },
    -- Rarely used source file indicator
    { regex = "^\\*{3} .+\n$",               type = "keyword"  },
    -- git patches seem to add 3 dashes to separate message from changed files
    { regex = "^\\-{3}\n$",                  type = "normal"   },
    -- Addition and deletion of lines
    { regex = "^\\-.*\n$",                   type = "diff_del" },
    { regex = "^\\+.*\n$",                   type = "diff_add" },
    { regex = "^<.*\n$",                     type = "diff_del" },
    { regex = "^>.*\n$",                     type = "diff_add" },
    -- Change between two lines
    { regex = "^!.*\n$",                     type = "number"   },
    -- Stuff usually found on a authored patch heading
    {
      pattern = "From ()[a-fA-F0-9]+ ().+\n",
      type = { "keyword", "number", "string" }
    },
    { regex = "^[a-zA-Z\\-]+: ",             type = "keyword" },
    -- Diff stats
    { regex = "^ [\\d]+ files? changed",     type = "function" },
    { regex = "[\\d]+ insertions?\\(\\+\\)", type = "diff_add" },
    { regex = "[\\d]+ deletions?\\(\\-\\)",  type = "diff_del" },
    -- Match e-mail
    {
      regex = "<[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+>\n",
      type = "keyword2"
    }
  },
  symbols = {}
}
