-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"
local RootView = require "core.rootview"
local DocView = require "core.docview"
local Doc = require "core.doc"

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
  return self.doc and self.doc.ephemeral and ("-- " .. get_name(self) .. " --") or get_name(self)
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
