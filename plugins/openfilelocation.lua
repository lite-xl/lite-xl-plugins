-- mod-version:3
local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"

local platform_filemanager
if PLATFORM == "Windows" then
  platform_filemanager = "explorer"
elseif PLATFORM == "Mac OS X" then
  platform_filemanager = "open"
else
  platform_filemanager = "xdg-open"
end

config.plugins.openfilelocation = common.merge({
  filemanager = platform_filemanager,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Open File Location",
    {
      label = "File Manager",
      description = "Command of the file browser.",
      path = "filemanager",
      type = "string",
      default = platform_filemanager
    }
  }
}, config.plugins.openfilelocation)

command.add("core.docview!", {
  ["open-file-location:open-file-location"] = function(dv)
    local doc = dv.doc
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
