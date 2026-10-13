-- mod-version:3
-- Move the treeview sidebar between the left and right edges of the window,
-- like VS Code's "Toggle Primary Side Bar Position".
local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local treeview = require "plugins.treeview"

config.plugins.sidebar_position = common.merge({
  -- Default edge when no toggled position has been remembered: "left" or "right".
  position = "left",
}, config.plugins.sidebar_position)

local state_file = USERDIR .. PATHSEP .. "sidebar_position"

-- The treeview (plus toolbar, when enabled) sits on one side of an hsplit
-- whose other side holds the editor nodes. Node layout and divider resizing
-- treat both sides symmetrically, so swapping them moves the sidebar.
local function sidebar_split()
  local node = treeview.node
  local parent = node and node:get_parent_node(core.root_view.root_node)
  if parent and parent.type == "hsplit" then return parent, node end
end

local function get_position()
  local parent, node = sidebar_split()
  if parent then return parent.a == node and "left" or "right" end
end

local function set_position(position)
  local parent = sidebar_split()
  if not parent then
    core.warn("Sidebar position: treeview layout not found")
    return false
  end
  if get_position() ~= position then
    parent.a, parent.b = parent.b, parent.a
    core.redraw = true
  end
  return true
end

local function load_position()
  local fp = io.open(state_file, "r")
  if not fp then return nil end
  local value = fp:read("*l")
  fp:close()
  if value == "left" or value == "right" then return value end
end

local function save_position(position)
  local fp = io.open(state_file, "w")
  if fp then
    fp:write(position, "\n")
    fp:close()
  end
end

set_position(load_position() or config.plugins.sidebar_position.position)

command.add(nil, {
  ["treeview:toggle-primary-sidebar-position"] = function()
    local position = get_position() == "left" and "right" or "left"
    if set_position(position) then save_position(position) end
  end,
  ["treeview:move-left"] = function()
    if set_position("left") then save_position("left") end
  end,
  ["treeview:move-right"] = function()
    if set_position("right") then save_position("right") end
  end,
})

return { get_position = get_position, set_position = set_position }
