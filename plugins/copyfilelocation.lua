-- mod-version:3
local core = require "core"
local command = require "core.command"
local treeview = require 'plugins.treeview'
local menu = treeview.contextmenu

command.add("core.docview!", {
  ["doc:copy-file-location"] = function(view)
    local doc = view.doc
    if not doc.abs_filename then
      core.error "Cannot copy location of unsaved doc"
      return
    end
    core.log("Copying \"%s\" to clipboard", doc.abs_filename)
    system.set_clipboard(doc.abs_filename)
  end
})

command.add(function()
  return treeview.hovered_item ~= nil, treeview.hovered_item
end, {
  ["treeview:copy-file-location"] = function(item)
    if not (item and item.abs_filename) then
      core.error "Cannot copy location of item"
      return
    end
    core.log("Copying \"%s\" to clipboard", item.abs_filename)
    system.set_clipboard(item.abs_filename)
  end
})

menu:register(nil, {
  { text = "Copy file location", command = "treeview:copy-file-location" }
})
