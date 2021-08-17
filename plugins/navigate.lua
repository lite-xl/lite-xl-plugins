-- mod-version:2 -- lite-xl 2.0

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local keymap = require "core.keymap"
local Doc = require "core.doc"
local DocView = require "core.docview"

local navigate = {
  list = {},
  current = nil,
  index = 0
}

--
-- Private functions
--
local function get_active_view()
  if getmetatable(core.active_view) == DocView then
    return core.active_view
  end
  return nil
end

-- Solution to safely remove elements from array table:
-- found at https://stackoverflow.com/a/53038524
local function array_remove(t, fnKeep)
  local j, n = 1, #t;

  for i=1, n do
    if (fnKeep(t, i, j)) then
      if (i ~= j) then
        t[j] = t[i];
        t[i] = nil;
      end
      j = j + 1;
    else
      t[i] = nil;
    end
  end

  return t;
end

local function add(doc)
  -- Make new navigation point last in list
  if navigate.index > 0 and navigate.index < #navigate.list then
    local remove_start = navigate.index + 1
    local remove_end = #navigate.list
    array_remove(navigate.list, function(_, i)
      if i >= remove_start and i <= remove_end then
        return false
      end
      return true
    end)
  end

  local line, col = doc:get_selection()
  table.insert(navigate.list, {
    filename = doc.filename,
    line = line,
    col = col
  })

  navigate.current = navigate.list[#navigate.list]
  navigate.index = #navigate.list
end

local function open_doc(doc)
  core.root_view:open_doc(
    core.open_doc(
      common.home_expand(
        doc.filename
      )
    )
  )

  local av_doc = get_active_view().doc
  local line, col = av_doc:get_selection()
  if doc.line ~= line or doc.col ~= col then
    av_doc:set_selection(doc.line, doc.col, doc.line, doc.col)
  end
end

--
-- Public functions
--
function navigate.next()
  if navigate.index < #navigate.list then
    navigate.index = navigate.index + 1
    navigate.current = navigate.list[navigate.index]
    open_doc(navigate.current)
  end
end

function navigate.prev()
  if navigate.index > 1 then
    navigate.index = navigate.index - 1
    navigate.current = navigate.list[navigate.index]
    open_doc(navigate.current)
  end
end

--
-- Thread
--
core.add_thread(function()
  while true do
    local av = get_active_view()
    if av and av.doc and av.doc.filename then
      local doc = av.doc
      local line, col = doc:get_selection()
      local current = navigate.current
      if
        not current
        or
        current.filename ~= doc.filename
        or
        current.line ~= line
      then
        add(doc)
      else
        current.col = col
      end
    end
    coroutine.yield(0.5)
  end
end)

--
-- Patching
--
local doc_on_close = Doc.on_close

function Doc:on_close()
  local filename = self.filename
  -- remove all positions referencing closed file
  array_remove(navigate.list, function(t, i)
    if t[i].filename == filename then
      return false
    end
    return true
  end)

  doc_on_close(self)
end

--
-- Commands
--
command.add("core.docview", {
  ["navigate:previous"] = function()
    navigate.prev()
  end,

  ["navigate:next"] = function()
    navigate.next()
  end,
})

--
-- Default Keybindings
--
keymap.add {
  ["alt+left"]    = "navigate:previous",
  ["alt+right"]   = "navigate:next",
}

return navigate
