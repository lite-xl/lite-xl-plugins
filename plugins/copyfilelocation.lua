-- mod-version:1 -- lite-xl 2.00
local core = require "core"
local command = require "core.command"

command.add("core.docview", {
  ["copy-file-location:copy-file-location"] = function()
    local doc = core.active_view.doc
    if not doc.abs_filename then
      core.error "Cannot copy location of unsaved doc"
      return
    end
    core.log("Copying to clipboard \"%s\"", doc.abs_filename)
    system.set_clipboard(doc.abs_filename)
  end
})
