-- mod-version:1 -- lite-xl 1.16

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"
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

local function add(doc)
  -- Make new navigation point last in list
  if navigate.index > 0 and navigate.index < #navigate.list then
    local list_len = #navigate.list
    for index=navigate.index+1, list_len, 1 do
      if navigate.list[index] then
        table.remove(navigate.list, index)
      end
    end
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

    if system.window_has_focus() then
      coroutine.yield(0.5)
    else
      coroutine.yield(config.project_scan_rate)
    end
  end
end)

core.add_close_hook(function(doc)
  local filename = doc.filename
  local list = {table.unpack(navigate.list)}
  for index, position in ipairs(list) do
    if position.filename == filename then
      if navigate.list[index] then
        table.remove(navigate.list, index)
      end
    end
  end
end)

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
