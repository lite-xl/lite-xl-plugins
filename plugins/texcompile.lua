-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local config = require "core.config"
local command = require "core.command"
local common = require "core.common"
local console = require "plugins.console"
local keymap = require "core.keymap"

-- This plugin requires the console plugin to work. It can be found at:
--
-- https://github.com/lite-xl/console
--
-- Before using this plugin add in your user's config file something like:
--
-- config.texcompile = {
--   latex_command = "pdflatex",
--   view_command = "evince",
-- }
--
-- On windows you may use the full path for the commands like:
--
-- config.texcompile = {
--   latex_command = [[c:\miktex\miktex\bin\x64\pdflatex.exe]],
--   view_command = [[c:\miktex\miktex\bin\x64\miktex-texworks.exe]],
-- }
--

command.add("core.docview", {
  ["texcompile:tex-compile"] = function()
    -- The current (La)TeX file and path
    local texname = core.active_view:get_name()
    local texpath = common.dirname(core.active_view:get_filename())
    local pdfname = texname:gsub("%.tex$", ".pdf")

    -- LaTeX compiler - is there any provided by the environment
    local texcmd = config.texcompile and config.texcompile.latex_command
    local viewcmd = config.texcompile and config.texcompile.view_command

    if not texcmd then
      core.log("No LaTeX compiler provided.")
    else
      core.log("LaTeX compiler is %s, compiling %s", texcmd, texname)

      console.run {
        command = string.format("%s %s && %s %s", texcmd, texname, viewcmd, pdfname),
        cwd = texpath,
        on_complete = function() core.log("Tex compiling command terminated.") end
      }
    end
  end,
})

keymap.add { ["ctrl+shift+t"] = "texcompile:tex-compile" }
