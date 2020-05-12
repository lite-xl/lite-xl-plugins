local core = require "core"
local command = require "core.command"
local config = require "core.config"


if PLATFORM == "Windows" then
  config.filemanager = "explorer"
else
  config.filemanager = "xdg-open"
end


command.add("core.docview", {
  ["open-file-location:open-file-location"] = function()
    local doc = core.active_view.doc
    if not doc.filename then
      core.error "Cannot open location of unsaved doc"
      return
    end
    local folder_name = doc.filename:match("^(.-)[^/\\]*$")
    core.log("Opening \"%s\"", folder_name)
    if PLATFORM == "Windows" then
      os.execute(string.format("start %s %s", config.filemanager, folder_name))
    else
      os.execute(string.format("%s %q", config.filemanager, folder_name))
    end
  end
})
