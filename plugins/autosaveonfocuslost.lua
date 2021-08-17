-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local CommandView = require "core.commandview"
local DocView = require "core.docview"
local RootView = require "core.rootview"

local on_focus_lost = RootView.on_focus_lost

local function save_node(node)
  if node.type == "leaf" then
    local i = 1
    while i <= #node.views do
      local view = node.views[i]
      if view:is(DocView) and not view:is(CommandView) and
         view.doc.filename and view.doc:is_dirty() then
        core.log("Saving doc \"%s\"", view.doc.filename)
        view.doc:save()
      end
      i = i + 1
    end
  else
    if node.a then save_node(node.a) end
    if node.b then save_node(node.b) end
  end
end

function RootView:on_focus_lost(...)
  save_node(core.root_view.root_node)

  return on_focus_lost(...)
end
