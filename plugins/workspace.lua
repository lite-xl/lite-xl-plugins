local core = require "core"
local DocView = require "core.docview"

local workspace_filename = core.project_dir .. "/.lite_workspace.lua"


local function serialize(val)
  if type(val) == "string" then
    return string.format("%q", val)
  elseif type(val) == "table" then
    local t = {}
    for k, v in pairs(val) do
      table.insert(t, "[" .. serialize(k) .. "]=" .. serialize(v))
    end
    return "{" .. table.concat(t, ",") .. "}"
  end
  return tostring(val)
end


local function has_no_locked_children(node)
  if node.locked then return false end
  if node.type == "leaf" then return true end
  return has_no_locked_children(node.a) and has_no_locked_children(node.b)
end


local function get_unlocked_root(node)
  if node.type == "leaf" then
    return not node.locked and node
  end
  if has_no_locked_children(node) then
    return node
  end
  return get_unlocked_root(node.a) or get_unlocked_root(node.b)
end


local function save_path(filename)
  local proj = system.absolute_path(core.project_dir)
  filename = system.absolute_path(filename)
  if filename:sub(1, #proj) == proj then
    return "." .. filename:sub(#proj + 1)
  end
  return filename
end


local function load_path(filename)
  return filename:gsub("^%.", core.project_dir)
end


local function save_docview(dv)
  return {
    filename = save_path(dv.doc.filename),
    selection = { dv.doc:get_selection() },
    scroll = { x = dv.scroll.to.x, y = dv.scroll.to.y }
  }
end


local function load_docview(t)
  local ok, doc = pcall(core.open_doc, load_path(t.filename))
  if not ok then
    return DocView(core.open_doc())
  end
  local dv = DocView(doc)
  doc:set_selection(table.unpack(t.selection))
  dv:update() -- prevents scrolling-to-make-caret-visible on initial frame
  dv.scroll.x, dv.scroll.to.x = t.scroll.x, t.scroll.x
  dv.scroll.y, dv.scroll.to.y = t.scroll.y, t.scroll.y
  return dv
end


local function save_node(node)
  local res = {}
  res.type = node.type
  if node.type == "leaf" then
    res.views = {}
    for _, view in ipairs(node.views) do
      if getmetatable(view) == DocView and view.doc.filename then
        table.insert(res.views, save_docview(view))
        if node.active_view == view then
          res.active_view = #res.views
        end
      end
    end
  else
    res.divider = node.divider
    res.a = save_node(node.a)
    res.b = save_node(node.b)
  end
  return res
end


local function load_node(node, t)
  if t.type == "leaf" then
    for _, dv in ipairs(t.views) do
      node:add_view(load_docview(dv))
    end
    if t.active_view then
      node:set_active_view(node.views[t.active_view])
    end
  else
    node:split(t.type == "hsplit" and "right" or "down")
    node.divider = t.divider
    load_node(node.a, t.a)
    load_node(node.b, t.b)
  end
end


local function save_workspace()
  local root = get_unlocked_root(core.root_view.root_node)
  local fp = io.open(workspace_filename, "w")
  fp:write("return ", serialize(save_node(root)), "\n")
  fp:close()
end


local function load_workspace()
  local ok, t = pcall(dofile, workspace_filename)
  if ok then
    local root = get_unlocked_root(core.root_view.root_node)
    load_node(root, t)
  end
end


local run = core.run

function core.run(...)
  if #core.docs == 0 then
    load_workspace()

    local exit = os.exit
    function os.exit(...)
      save_workspace()
      exit(...)
    end
  end

  core.run = run
  return core.run(...)
end
