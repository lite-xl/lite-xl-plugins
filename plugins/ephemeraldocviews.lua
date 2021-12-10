-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"
local RootView = require "core.rootview"
local DocView = require "core.docview"
local Doc = require "core.doc"
local TreeView = require "plugins.treeview"

local open_doc = RootView.open_doc
function RootView:open_doc(doc)
  local node = self:get_active_node_default()
  local ephemeral, existing_ephemeral = node.views, nil
  for i, view in ipairs(node.views) do
    if view.doc == doc then
      ephemeral = false
    end
    if view.doc and view.doc.ephemeral then
      existing_ephemeral = view
    end
  end
  if ephemeral and existing_ephemeral then
    node:close_view(self.root_node, existing_ephemeral)
  end
  local view = open_doc(self, doc)
  if ephemeral then
    view.doc.ephemeral = #node.views > 1
  end
  return view
end

local get_name = DocView.get_name
function DocView:get_name()
  return self.doc and self.doc.ephemeral and ("~ " .. get_name(self) .. " ~") or get_name(self)
end

local doc_insert = Doc.insert
function Doc:insert(...)
  doc_insert(self, ...)
  self.ephemeral = false
end

local doc_remove = Doc.remove
function Doc:remove(...)
  doc_remove(self, ...)
  self.ephemeral = false
end

-- Double clicking in the TreeView makes the tab normal
local TreeView_original_event = TreeView.on_mouse_pressed
function TreeView:on_mouse_pressed(button, x, y, clicks)
  TreeView_original_event(self, button, x, y, clicks)
  if (clicks > 1) and (core.active_view.doc ~= nil) then
    core.active_view.doc.ephemeral = false
  end
end

-- Double clicking on a tab makes it normal
local RootView_original_event = RootView.on_mouse_pressed
function RootView:on_mouse_pressed(button, x, y, clicks)
  if RootView_original_event(self, button, x, y, clicks) then
    if clicks > 1 then
      local node = self.root_node:get_child_overlapping_point(x, y)
      local idx = node:get_tab_overlapping_point(x, y)
      if idx then
        node.views[idx].doc.ephemeral = false
      end
    end
    return true
  end
end
