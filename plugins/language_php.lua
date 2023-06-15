-- mod-version:3
--[[
  language_php.lua
  provides php syntax support allowing mixed html, css and js
  version: 20220614_1
--]]
local syntax = require "core.syntax"
local common = require "core.common"
local config = require "core.config"

-- load syntax dependencies to add additional rules
require "plugins.language_css"
require "plugins.language_js"

local psql_found = pcall(require, "plugins.language_psql")
local sql_strings = {}

config.plugins.language_php = common.merge({
  sql_strings = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Language PHP",
    {
      label = "SQL Strings",
      description = "Highlight as SQL, strings starting with sql statements, "
        .. "depends on language_psql.",
      path = "sql_strings",
      type = "toggle",
      default = true,
      on_apply = function(enabled)
        local syntax_php = syntax.get("file.phps")
        if enabled and psql_found then
          if
            not syntax_php.patterns[6].syntax
            or
            syntax_php.patterns[6].syntax ~= '.sql'
          then
            table.insert(syntax_php.patterns, 5, sql_strings[1])
            table.insert(syntax_php.patterns, 6, sql_strings[2])
          end
        elseif
          syntax_php.patterns[6].syntax
          and
          syntax_php.patterns[6].syntax == '.sql'
        then
          table.remove(syntax_php.patterns, 5)
          table.remove(syntax_php.patterns, 5)
        end
      end
    }
  }
}, config.plugins.language_php)

-- Patterns to match some of the string inline variables
local inline_variables = {
  { pattern = "%s+",           type = "string" },
  { pattern = "\\%$",          type = "string" },
  { pattern = "%{[%$%s]*%}",   type = "string" },
  -- matches {$varname[index]}
  { pattern = "{"
      .. "()%$[%a_][%w_]*"
      .. "()%["
      .. "()[%w%s_%-\"\'%(%)|;:,%.#@%%!%^&%*%+=%[%]<>~`%?\\/]*"
      .. "()%]"
      .. "}",
    type = {
      "keyword", "keyword2", "keyword", "string", "keyword"
    }
  },
  { pattern = "{"
      .. "()%$[%a_][%w_]*"
      .. "()%->"
      .. "()[%a_][%w_]*"
      .. "()}",
    type = {
      "keyword", "keyword2", "keyword", "symbol", "keyword"
    }
  },
  { pattern = "{()%$[%a_][%w_]*()}",
    type = { "keyword", "keyword2", "keyword" }
  },
  { pattern = "%$[%a_][%w_]*()%[()[%w_]*()%]",
    type = { "keyword2", "keyword", "string", "keyword" }
  },
  { pattern = "%$[%a_][%w_]*()%->()%a[%w_]*",
    type = { "keyword2", "keyword", "symbol" }
  },
  { pattern = "%$[%a_][%w_]*", type = "keyword2" },
  { pattern = "%w+",           type = "string" }
}

local function combine_patterns(t1, t2)
  local temp = { table.unpack(t1) }
  for _, t in ipairs(t2) do
    table.insert(temp, t)
  end
  return temp
end

local function clone(tbl)
  local t = {}
  if tbl then
    for k, v in pairs(tbl) do
      if type(v) == "table" then
        t[k] = clone(v)
      else
        t[k] = v
      end
    end
  end
  return t
end

-- optionally allow sql syntax on strings
if psql_found then
  -- generate SQL string marker regex
  local sql_markers = { 'create', 'select', 'insert', 'update', 'replace', 'delete', 'drop', 'alter' }
  local sql_regex = table.concat(sql_markers, '|')

  -- inject inline variable rules to cloned psql syntax
  local syntax_phpsql = clone(syntax.get("file.sql"))
  syntax_phpsql.name = "PHP SQL"
  syntax_phpsql.files = "%.phpsql$"
  table.insert(syntax_phpsql.patterns, 2, { pattern = "\\%$", type = "symbol" })
  table.insert(syntax_phpsql.patterns, 3, { pattern = "%{[%$%s]*%}", type = "symbol" })
  for i=4, 9 do
    table.insert(syntax_phpsql.patterns, i, inline_variables[i])
  end

  -- SQL strings
  sql_strings = {
    {
        regex  = { '"(?=[\\s(]*(?i:'..sql_regex..')\\s+)', '"', '\\' },
        syntax = syntax_phpsql,
        type   = "string"
    },
    {
        regex  = { "'(?=[\\s(]*(?i:"..sql_regex..")\\s+)", '\'', '\\' },
        syntax = '.sql',
        type   = "string"
    },
  }
end

-- define the core php syntax coloring
syntax.add {
  name = "PHP Source",
  files = { "%.phps$" },
  headers = "^<%?php",
  comment = "//",
  block_comment = {"/*", "*/"},
  patterns = {
    -- Attributes
    { pattern = {"#%[", "%]"},               type = "normal"   },
    -- Comments
    { pattern = "//.-\n",                    type = "comment"  },
    { pattern = "#.-\n",                     type = "comment"  },
    { pattern = { "/%*", "%*/" },            type = "comment"  },
    -- Single quote string
    { pattern = { "'", "'", '\\' },          type = "string"   },
    { pattern = { "<<<'%a%w*'\n", "^%s*%a%w*%f[;]", '\\' },
      type = "string"
    },
    -- Strings with support for some inline variables syntax
    { pattern = { "<<<%a%w*\n", "^%s*%a%w*%f[;]", '\\' },
      syntax = {
        patterns = combine_patterns(inline_variables, {
          -- prevent matching outside of the parent string
          { pattern = "^%s*%a%w*();$",
            type = { "string", "normal" }
          },
          { pattern = "%p", type = "string" },
        }),
        symbols = {}
      },
      type = "string"
    },
    { pattern = { '"', '"', '\\' },
      syntax = {
        patterns = combine_patterns(inline_variables, {
          -- prevent matching outside of the parent string
          { pattern = "[^\"]",         type = "string" },
          { pattern = "%p+%f[\"]",     type = "string" },
          { pattern = "%p",            type = "string" },
        }),
        symbols = {}
      },
      type = "string"
    },
    { pattern = { '`', '`', '\\' },
      syntax = {
        patterns = combine_patterns(inline_variables, {
          -- prevent matching outside of the parent string
          { pattern = "[^`]",          type = "string" },
          { pattern = "%p+%f[`]",      type = "string" },
          { pattern = "%p",            type = "string" },
        }),
        symbols = {}
      },
      type = "string"
    },
    { pattern = "0[bB][%d]+",                 type = "number"   },
    { pattern = "0[xX][%da-fA-F]+",           type = "number"   },
    { pattern = "-?%d[%d_%.eE]*",             type = "number"   },
    { pattern = "-?%.?%d+",                   type = "number"   },
    { pattern = "[%.%+%-=/%*%^%%<>!~|&%?:@]", type = "operator" },
     -- Variables
    { pattern = "%$[%w_]+",                   type = "keyword2" },
    -- Respect control structures, treat as keyword not function
    { pattern = "if[%s]*%f[(]",               type = "keyword"  },
    { pattern = "else[%s]*%f[(]",             type = "keyword"  },
    { pattern = "elseif[%s]*%f[(]",           type = "keyword"  },
    { pattern = "for[%s]*%f[(]",              type = "keyword"  },
    { pattern = "foreach[%s]*%f[(]",          type = "keyword"  },
    { pattern = "while[%s]*%f[(]",            type = "keyword"  },
    { pattern = "catch[%s]*%f[(]",            type = "keyword"  },
    { pattern = "switch[%s]*%f[(]",           type = "keyword"  },
    { pattern = "match[%s]*%f[(]",            type = "keyword"  },
    { pattern = "fn[%s]*%f[(]",               type = "keyword"  },
    -- All functions that aren't control structures
    { pattern = "[%a_][%w_]*[%s]*%f[(]",      type = "function" },
    -- Array type hint not added on symbols to also make it work
    -- as a function call
    { pattern = "array",                      type = "literal"  },
    -- Match static or namespace container on sub element access
    { pattern = "[%a_][%w_]*[%s]*%f[:]",      type = "literal"  },
    -- Uppercase constants of at least 2 chars in len
    {
        pattern = "%u[%u_][%u%d_]*%f[%s%+%*%-%.%(%)%?%^%%=/<>~|&;:,!]",
        type = "number"
    },
    -- Magic constants
    { pattern = "__[%u]+__",                  type = "number"   },
    -- Everything else
    { pattern = "[%a_][%w_]*",                type = "symbol"   },
  },
  symbols = {
    ["return"] = "keyword",
    ["if"] = "keyword",
    ["else"] = "keyword",
    ["elseif"] = "keyword",
    ["endif"] = "keyword",
    ["declare"] = "keyword",
    ["enddeclare"] = "keyword",
    ["switch"] = "keyword",
    ["endswitch"] = "keyword",
    ["as"] = "keyword",
    ["do"] = "keyword",
    ["for"] = "keyword",
    ["endfor"] = "keyword",
    ["foreach"] = "keyword",
    ["endforeach"] = "keyword",
    ["while"] = "keyword",
    ["endwhile"] = "keyword",
    ["match"] = "keyword",
    ["case"] = "keyword",
    ["continue"] = "keyword",
    ["default"] = "keyword",
    ["break"] = "keyword",
    ["goto"] = "keyword",
    ["yield"] = "keyword",

    ["try"] = "keyword",
    ["catch"] = "keyword",
    ["throw"] = "keyword",
    ["finally"] = "keyword",

    ["class"] = "keyword",
    ["enum"] = "keyword",
    ["trait"] = "keyword",
    ["interface"] = "keyword",
    ["public"] = "keyword",
    ["static"] = "keyword",
    ["protected"] = "keyword",
    ["private"] = "keyword",
    ["readonly"] = "keyword",
    ["abstract"] = "keyword",
    ["final"] = "keyword",
    ["$this"] = "literal",

    ["function"] = "keyword",
    ["fn"] = "keyword",
    ["global"] = "keyword",
    ["var"] = "keyword",
    ["const"] = "keyword",

    ["bool"] = "literal",
    ["boolean"] = "literal",
    ["int"] = "literal",
    ["integer"] = "literal",
    ["real"] = "literal",
    ["double"] = "literal",
    ["float"] = "literal",
    ["string"] = "literal",
    ["object"] = "literal",
    ["callable"] = "literal",
    ["iterable"] = "literal",
    ["void"] = "literal",
    ["parent"] = "literal",
    ["self"] = "literal",
    ["mixed"] = "literal",
    ["never"] = "literal",

    ["namespace"] = "keyword",
    ["extends"] = "keyword",
    ["implements"] = "keyword",
    ["instanceof"] = "keyword",
    ["require"] = "keyword",
    ["require_once"] = "keyword",
    ["include"] = "keyword",
    ["include_once"] = "keyword",
    ["use"] = "keyword",
    ["new"] = "keyword",
    ["clone"] = "keyword",

    ["true"] = "number",
    ["false"] = "number",
    ["NULL"] = "number",
    ["null"] = "number",

    ["print"] = "function",
    ["echo"] = "function",
    ["exit"] = "function",
  },
}

-- insert sql string rules after the "/%*", "%*/" pattern
if psql_found and config.plugins.language_php.sql_strings then
  local syntax_php = syntax.get("file.phps")
  table.insert(syntax_php.patterns, 5, sql_strings[1])
  table.insert(syntax_php.patterns, 6, sql_strings[2])
end

-- allows html, css and js coloring on php files
syntax.add {
  name = "PHP",
  files = { "%.php$", "%.phtml" },
  block_comment = { "<!--", "-->" },
  patterns = {
    {
      regex = {
        "<\\?php\\s+",
        "(?:\\?>|(?=`{3}))" -- end if inside markdown code tags
      },
      syntax = ".phps",
      type = "keyword2"
    },
    {
      pattern = {
        "<%?=?",
        "%?>"
      },
      syntax = ".phps",
      type = "keyword2"
    },
    {
      pattern = {
        "<%s*[sS][cC][rR][iI][pP][tT]%f[%s>].->",
        "<%s*/%s*[sS][cC][rR][iI][pP][tT]%s*>"
      },
      syntax = ".js",
      type = "function"
    },
    {
      pattern = {
        "<%s*[sS][tT][yY][lL][eE]%f[%s>].->",
        "<%s*/%s*[sS][tT][yY][lL][eE]%s*>"
      },
      syntax = ".css",
      type = "function"
    },
    { pattern = { "<!%-%-", "%-%->" },     type = "comment"  },
    { pattern = { '%f[^>][^<]', '%f[<]' }, type = "normal"   },
    { pattern = { '"', '"', '\\' },        type = "string"   },
    { pattern = { "'", "'", '\\' },        type = "string"   },
    { pattern = "0x[%da-fA-F]+",           type = "number"   },
    { pattern = "-?%d+[%d%.]*f?",          type = "number"   },
    { pattern = "-?%.?%d+f?",              type = "number"   },
    { pattern = "%f[^<]![%a_][%w_]*",      type = "keyword2" },
    { pattern = "%f[^<][%a_][%w_]*",       type = "function" },
    { pattern = "%f[^<]/[%a_][%w_]*",      type = "function" },
    { pattern = "[%a_][%w_]*",             type = "keyword"  },
    { pattern = "[/<>=]",                  type = "operator" },
    -- match markdown code tags to be able to end php highlighting
    -- when inside the subsyntax .phps
    { regex = "(?=`{3})",                  type = "string"   }
  },
  symbols = {},
}

-- allow coloring of php code inside css and js code
local syntaxes = { "css", "js" }
for _, ext in pairs(syntaxes) do
  local syntax_table = syntax.get("file."..ext, "")

  table.insert(
    syntax_table.patterns,
    1,
    {
      pattern = {
        "<%?=?",
        "%?>"
      },
      syntax = ".phps",
      type = "keyword2"
    }
  )

  table.insert(
    syntax_table.patterns,
    1,
    {
      pattern = {
        "<%?php%s+",
        "%?>"
      },
      syntax = ".phps",
      type = "keyword2"
    }
  )
end
