-- mod-version:3.1
local core = require "core"
local config = require "core.config"
local command = require "core.command"
local common = require "core.common"
local keymap = require "core.keymap"
local RootView = require "core.rootview"
local DocView = require "core.docview"
local Doc = require "core.doc"

config.plugins.ephemeral_tabs = common.merge({
  -- Mark tabs as ephemeral when opening from the treeview.
  treeview = true,
  -- Mark tabs as ephemeral when opening from the project search.
  projectsearch = true,
  -- Mark tabs as ephemeral in all other cases. Can take a function.
  default = false,
  config_spec = {
    name = "Treeview",
    {
      label = "Ephemeralize TreeView",
      description = "Ephemeralize tabs opened from TreeView.",
      path = "treeview",
      type = "toggle",
      default = true
    },
    {
      label = "Ephemeralize ProjectSearch",
      description = "Ephemeralize tabs opened from ProjectSearch.",
      path = "projectsearch",
      type = "toggle",
      default = true
    },
    {
      label = "Ephemeralize by default",
      description = "Ephemeralize tabs opened any other way.",
      path = "default",
      type = "toggle",
      default = false
    }
  }
}, config.plugins.ephemeral_tabs)


local TreeView, ProjectSearch
local callee = "startup"


config.plugins.treeview.onload = function(tv)
  TreeView = tv
  local old_open_doc = TreeView.open_doc
  if old_open_doc then
    function TreeView:open_doc(filename)
      callee = TreeView
      local status, err = pcall(old_open_doc, self, filename)
      callee = nil
      if not status then error(err) end
    end
  end
  command.add(function()
    return core.active_view == TreeView and TreeView.hovered_item
  end, {
    ["treeview:deephemeralize"] = function()
      core.root_view:open_doc(core.open_doc(TreeView.hovered_item.abs_filename)).ephemeral = false
    end
  })
  keymap.add {
    ["2lclick"] = "treeview:deephemeralize"
  }
end


config.plugins.projectsearch.onload = function(ps)
  ProjectSearch = ps
  local old_open_doc = ProjectSearch.ResultsView.open_selected_result
  function ProjectSearch.ResultsView:open_selected_result()
    callee = ProjectSearch
    local status, err = old_open_doc(self)
    callee = nil
    if not status then error(err) end
  end
end


local DocView_new = DocView.new
function DocView:new(doc)
  DocView_new(self, doc)
  if callee then
    self.ephemeral = callee ~= "startup" and (callee == TreeView and config.plugins.ephemeral_tabs.treeview) or (callee == ProjectSearch and config.plugins.ephemeral_tabs.projectsearch)
  elseif type(config.plugins.ephemeral_tabs.default) == "function" then
    self.ephemeral = config.plugins.ephemeral_tabs.default(docview)
  elseif config.plugins.ephemeral_tabs.default then
    self.ephemeral = config.plugins.ephemeral_tabs.default
  end
end


local RootView_open_doc = RootView.open_doc
function RootView:open_doc(doc)
  local docview = RootView_open_doc(self, doc)
  if docview.ephemeral then
    local node = self:get_active_node_default()
    for i, v in ipairs(node.views) do
      if v.ephemeral and docview ~= v then
        node:close_view(self.root_node, v)
      end
    end
  end
  return docview
end


local DocView_get_name = DocView.get_name
function DocView:get_name()
  return self.doc and self.ephemeral and ("~ " .. DocView_get_name(self) .. " ~")
          or DocView_get_name(self)
end


-- Any change to the document makes the tab normal
local Doc_on_text_change = Doc.on_text_change
function Doc:on_text_change(type)
  if core.active_view.doc == self then
    core.active_view.ephemeral = false
  end
  Doc_on_text_change(self, type)
end


--- Double clicking on a tab makes it normal
local RootView_on_mouse_pressed = RootView.on_mouse_pressed
function RootView:on_mouse_pressed(button, x, y, clicks)
  local result = RootView_on_mouse_pressed(self, button, x, y, clicks)
  if clicks > 1 then
    local node = self.root_node:get_child_overlapping_point(x, y)
    local idx = node:get_tab_overlapping_point(x, y)
    if idx then
      node.views[idx].ephemeral = false
    end
   end
  return result
end


-- Dragging a tab deephemeralizes
local RootView_on_mouse_released = RootView.on_mouse_released
function RootView:on_mouse_released(button, x, y, ...)
  if self.dragged_node then
    if button == "left" then
      if self.dragged_node.dragging then
        local view = self.dragged_node.node.views[self.dragged_node.idx]
        view.ephemeral = false
      end
    end
  end
  return RootView_on_mouse_released(self, button, x, y, ...)
end


local core_run = core.run
function core.run()
  callee = nil
  core_run()
end

