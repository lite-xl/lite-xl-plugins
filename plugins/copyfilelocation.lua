local core = require "core"
local command = require "core.command"
local config = require "core.config"


command.add("core.docview", {
  ["copy-file-location:copy-file-location"] = function()
    local doc = core.active_view.doc
    if not doc.filename then
      core.error "Cannot copy location of unsaved doc"
      return
    end
    local filename = system.absolute_path(doc.filename)
    core.log("Copying to clipboard \"%s\"", filename)
    system.set_clipboard(filename)
  end
})
