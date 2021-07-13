-- mod-version:1 -- lite-xl 2.00
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"

command.add("core.docview", {
  ["texcompile:tex-compile"] = function()
    local av = core.active_view

-- User's home directory
    local homedir = ""

    if PLATFORM == "Windows" then
        homedir = os.getenv("USERPROFILE")
    else
        homedir = os.getenv("HOME")
    end

-- The current (La)TeX file and path
    local texname = av:get_name()
    local texpath = av:get_filename()
    texpath = string.gsub(texpath, '~', homedir)
    texpath = string.gsub(texpath, texname, '')

-- LaTeX compiler - is there any provided by the environment
    local texcmd = os.getenv("LITE_LATEX_COMPILER")

    if texcmd == nil then
        core.log("No LaTeX compiler found")
    else
        core.log("LaTeX compiler is %s, compiling %s", texcmd, texname)

        system.exec(string.format("cd %q && %q %q", texpath, texcmd, texname))
    end

--    core.add_thread(function()
--      coroutine.yield(5)
--      os.remove(htmlfile)
--    end)
  end
})


keymap.add { ["ctrl+shift+t"] = "texcompile:tex-compile" }
