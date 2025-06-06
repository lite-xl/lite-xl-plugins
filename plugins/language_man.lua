-- mod-version:3
local syntax = require "core.syntax"
local style = require "core.style"
local core = require "core"

local initial_color = style.syntax["keyword2"]

local default_sh = {
  "NAME",
  "SYNOPSIS",
  "CONFIGURATION",
  "DESCRIPTION",
  "OPTIONS",
  "EXIT STATUS",
  "RETURN VALUE",
  "ERRORS",
  "ENVIRONMENT",
  "FILES",
  "VERSIONS",
  "CONFORMING TO",
  "NOTES",
  "BUGS",
  "EXAMPLE",
  "SEE ALSO"
}

for i, name in pairs(default_sh) do
  default_sh[i] = { pattern = "^%s*%.SH%s"..name, type = "keyword" }
end

local function append(t1, ...)
  local t2 = {...}
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end

-- yoinked from markdown
for _, attr in pairs({"bold", "italic", "bold_italic"}) do
  local attributes = {}
  if attr ~= "bold_italic" then
    attributes[attr] = true
  else
    attributes["bold"] = true
    attributes["italic"] = true
  end
  -- no way to copy user custom font with additional attributes :(
  style.syntax_fonts["roff_"..attr] = renderer.font.load(
    DATADIR .. "/fonts/JetBrainsMono-Regular.ttf",
    style.code_font:get_size(),
    attributes
  )
  -- also add a color for it
  style.syntax["roff_"..attr] = style.syntax["keyword2"]
end

syntax.add {
	name = "Manual",
  files = { -- There are quite a lot, cfr: https://www.man7.org/linux/man-pages/man5/groff_filenames.5.html
		-- man page sections
		"%.[1-8lno]$",
		-- roff
		"%.mdoc$", "%.man$",
		-- troff
		"%.m[ems]$", "%.tr?$",
		-- preprocessors
		"%.chem$", "%.eqn$", "%.pic$", "%.tbl$", "%.ref$", "%.hdtbl$", "%.grap$", "%.pdfroff$",
		-- groff
		"%.g?roff$", "%.tmac$", "%.mmse$", "%.mom$"
	},
  patterns = append(append({}, table.unpack(default_sh)),
    { pattern = "\\()%-", type = { "operator", "normal"}},
    -- .TH title section date source manual 
    {
      pattern = "^%s*%.TH".."()%s+[%u%d-]+".."()%s+[1-8]".."()%s+%d%d%d%d%-%d%d%-%d%d".."().*",
      type = { "keyword", "roff_bold", "number", "roff_italic", "literal" }
    },
    --headings and sub-headings
    { pattern = "^%s*%.S[HS]%s()[%w ]+", type = { "keyword", "literal" }},
    --fonts (bold, italic)
    { pattern = "^%s*%.BI()%s+[^%s]+()%s*[^%s]+().+", type = {"function", "roff_bold", "roff_italic", "roff_bold_italic"}},
    { pattern = "^%s*%.IB()%s+[^%s]+()%s*[^%s]+().+", type = {"function", "roff_italic", "roff_bold", "roff_bold_italic" }},
    { pattern = "^%s*%.RB()%s+[^%s]+()%s*[^%s]+().+", type = {"function", "normal", "roff_bold" }},
    { pattern = "^%s*%.RI()%s+[^%s]+()%s*[^%s]+().+", type = {"function", "normal", "roff_italic" }},
    { pattern = "^%s*%.B().*",                        type = {"function", "roff_bold" }},
    { pattern = "^%s*%.I().*",                        type = {"function", "roff_italic" }},
    { pattern = { "\\fI", "\\f[PR]" },                type = "roff_italic" },
    { pattern = { "\\fB", "\\f[PR]" },                type = "roff_bold" },
    --paragraphs
    { regex = [[^\s*\.(?:[TIP]?P)\s]],               type = "keyword2" },
    { regex = [[^\s*\.(?:R[SE]|PD|sp|in|nf|fi)\s]],  type = "keyword2" },
    --misc
    { regex = [[^\s*['\.]\\"]],                      type = "comment" },
    { pattern = { "'", "'" },                        type = "literal" },
    { pattern = "\\f(CW)().*()\\fR", type = {"operator", "literal", "operator"}},
    { pattern = { "%.TS", "%.TE" }, type = "keyword2", syntax = ".tbl"}
  ),
	symbols = {
    [ "^%.TH" ] = "keyword",
    [ "\\fI" ] = "operator",
    [ "\\fB" ] = "operator",
    [ "\\fP" ] = "operator",
    [ "\\fR" ] = "operator"
	},
}

syntax.add {
	name = "Manual",
  files = { "%.eqn$" },
  patterns = {},
  symbols = {
    ["sqrt"]  = "function",
    ["sum"]   = "function",
    ["int"]   = "function",
    ["sub"]   = "function",
    ["sup"]   = "function",

    ["from"]  = "keyword",
    ["to"]    = "keyword",

    ["over"]  = "operator",
    ["left"]  = "operator",
    ["right"] = "operator",
  },
}

syntax.add {
  name = "Manual",
  files = { "%.pic$" },
  patterns = {},
  symbols = {
    ["box"]     = "literal",
    ["circle"]  = "literal",
    ["ellipse"] = "literal",
    ["line"]    = "literal",
    ["arrow"]   = "literal",

    ["move"]    = "function",
    ["then"]    = "keyword",
    ["up"]      = "operator",
    ["down"]    = "operator",
    ["left"]    = "operator",
    ["right"]   = "operator",

    ["from"]    = "keyword",
    ["to"]      = "keyword",
    ["at"]      = "keyword",
    ["with"]    = "keyword",
    ["above"]   = "keyword",
    ["below"]   = "keyword",

    ["define"]  = "keyword",
    ["copy"]    = "keyword",
    ["reset"]   = "keyword",
  },
}

syntax.add {
  name = "Manual",
  files = { "%.tbl$" },
  patterns = {
    { regex = [=[^\s*\.T[SE&]]=], type = "keyword" },
    { regex = [[box|center|expand|tab|allbox]], type = "keyword2" },
    { pattern = "[lcrna]", type = "literal" },
    { pattern = "[|=]+", type = "operator" },
  }
}

-- Adjust the color on theme changes
core.add_thread(function()
  while true do
    if initial_color ~= style.syntax["keyword2"] then
      for _, attr in pairs({"bold", "italic", "bold_italic"}) do
        style.syntax["markdown_"..attr] = style.syntax["keyword2"]
      end
      initial_color = style.syntax["keyword2"]
    end
    coroutine.yield(1)
  end
end)

