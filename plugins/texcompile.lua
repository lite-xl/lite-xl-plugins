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
-- as long as the commands are in your PATH.
--
-- Options can be passed as part of the command for example like in:
--
-- latex_command = "latex -pdf -pdflatex -c".
--
-- On Windows, if the commands are not in your PATH, you may use the full path
-- of the executable like, for example:
--
-- config.texcompile = {
--   latex_command = [[C:\miktex\miktex\bin\x64\pdflatex.exe]],
--   view_command = [[C:\Program^ Files\SumatraPDF\SumatraPDF.exe]],
-- }
--
-- Note that in the example we have used "^ " for spaces that appear in the path.
-- It is required on Windows for path or file names that contains space characters.

command.add("core.docview", {
  ["texcompile:tex-compile"] = function()
    -- The current (La)TeX file and path
    local texname = core.active_view:get_name()
    local texpath = common.dirname(core.active_view:get_filename())
    local pdfname = texname:gsub("%.tex$", ".pdf")

    -- LaTeX compiler as configured in config.texcompile
    local texcmd = config.texcompile and config.texcompile.latex_command
    local viewcmd = config.texcompile and config.texcompile.view_command

    if not texcmd then
      core.log("No LaTeX compiler provided in config.")
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
