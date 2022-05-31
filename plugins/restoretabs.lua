-- mod-version:3
-- Not perfect, because we can't actually figure out when something closes, but should be good enough, so long as we check the list of open views.
-- Maybe find a better way to get at "Node"?
local core = require "core"
local RootView = require "core.rootview"
local command = require "core.command"
local keymap = require "core.keymap"

local update = RootView.update
local initialized_tab_system = false

local tab_history = { }
local history_size = 10

RootView.update = function(self)
  update(self)
  if not initialized_tab_system then
    local Node = getmetatable(self.root_node)
    local old_close = Node.close_view

    Node.close_view = function(self, root, view)
      if view.doc and view.doc.abs_filename then
        local closing_filename = view.doc.abs_filename
        for i,filename in ipairs(tab_history) do
          if filename == closing_filename then
            table.remove(tab_history, i)
            break
          end
        end
        table.insert(tab_history, closing_filename)
        if #tab_history > history_size then
          table.remove(tab_history, 1)
        end
      end
      old_close(self, root, view)
    end

    initialized_tab_system = true
  end
end


command.add(nil, {
  ["restore-tabs:restore-tab"] = function()
    if #tab_history > 0 then
      local file = tab_history[#tab_history]
      core.root_view:open_doc(core.open_doc(file))
      table.remove(tab_history)
    end
  end
})

keymap.add {
  ["ctrl+shift+t"] = "restore-tabs:restore-tab"
}
