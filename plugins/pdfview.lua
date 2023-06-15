-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"

command.add("core.docview!", {
  ["pdfview:show-preview"] = function(av)
-- User's home directory
    local homedir = ""

    if PLATFORM == "Windows" then
        homedir = os.getenv("USERPROFILE")
    else
        homedir = os.getenv("HOME")
    end

-- The current (La)TeX file
    local texfile = av:get_filename()
    texfile = string.gsub(texfile, '~', homedir)
-- Construct the PDF file name out of the (La)Tex filename
    local pdffile = "\"" .. string.gsub(texfile, ".tex", ".pdf") .. "\""
-- PDF viewer - is there any provided by the environment
    local pdfcmd = os.getenv("LITE_PDF_VIEWER")

    core.log("Opening pdf preview for \"%s\"", texfile)

    if pdfcmd ~= nil then
        system.exec(pdfcmd .. " " .. pdffile)
    elseif PLATFORM == "Windows" then
        system.exec("start " .. pdffile)
    else
        system.exec(string.format("xdg-open %q", pdffile))
    end

--    core.add_thread(function()
--      coroutine.yield(5)
--      os.remove(htmlfile)
--    end)
  end
})


keymap.add { ["ctrl+shift+v"] = "pdfview:show-preview" }
