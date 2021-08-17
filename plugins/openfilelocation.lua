-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"
local config = require "core.config"


config.plugins.openfilelocation = {}
if PLATFORM == "Windows" then
  config.plugins.openfilelocation.filemanager = "explorer"
elseif PLATFORM == "Mac OS X" then
  config.plugins.openfilelocation.filemanager = "open"
else
  config.plugins.openfilelocation.filemanager = "xdg-open"
end


command.add("core.docview", {
  ["open-file-location:open-file-location"] = function()
    local doc = core.active_view.doc
    if not doc.filename then
      core.error "Cannot open location of unsaved doc"
      return
    end
    local folder = doc.filename:match("^(.*)[/\\].*$") or "."
    core.log("Opening \"%s\"", folder)
    if PLATFORM == "Windows" then
      system.exec(string.format("%s %s", config.plugins.openfilelocation.filemanager, folder))
    else
      system.exec(string.format("%s %q", config.plugins.openfilelocation.filemanager, folder))
    end
  end
})
