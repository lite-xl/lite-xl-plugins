-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require "core.common"
local DocView = require "core.docview"

local nodes_visit_order = setmetatable({}, {__mode = "k"})

local order_counter = 0

local core_set_active_view = core.set_active_view
function core.set_active_view(view)
  nodes_visit_order[view] = order_counter
  order_counter = order_counter + 1
  return core_set_active_view(view)
end

local tab_switcher = {}
function tab_switcher.get_tab_list(base_node)
  local raw_list = base_node:get_children()
  local list = {}
  local mt = {
    -- fuzzy_match uses tostring to get the text to compare
    __tostring = function(i) return i.text end
  }
  for _,v in pairs(raw_list) do
    if v:is(DocView) then
      table.insert(list, setmetatable({
        text = v:get_name(),
        view = v
      }, mt))
    end
  end
  table.sort(list, function(a, b)
    return (nodes_visit_order[a.view] or -1) > (nodes_visit_order[b.view] or -1)
  end)
  if #list > 1 then
    -- Set last element to be the previously focused tab,
    -- so that pressing enter is enough to switch to it.
    local last = list[1]
    list[1] = list[2]
    list[2] = last
  end
  return list
end

local function set_active_view(view)
  local n = core.root_view.root_node:get_node_for_view(view)
  if n then n:set_active_view(view) end
end

local function ask_selection(label, items)
  core.command_view:enter(label, {
    submit = function(_, item)
      set_active_view(item.view)
    end,
    suggest = function(text)
      if #text > 1 then
        return common.fuzzy_match(items, text, true)
      else
        return items
      end
    end,
    validate = function(_, item)
      return item
    end
  })
end

command.add(function()
    local items = tab_switcher.get_tab_list(core.root_view.root_node)
    return #items > 0, items
  end, {
  ["tab-switcher:tab-list"] = function(items)
    ask_selection("Switch to tab", items)
  end,
  ["tab-switcher:switch-to-last-tab"] = function(items)
    set_active_view(items[1].view)
  end,
})

command.add(function()
    local items = tab_switcher.get_tab_list(core.root_view:get_active_node())
    return #items > 0, items
  end, {
  ["tab-switcher:tab-list-current-split"] = function(items)
    ask_selection("Switch to tab in current split", items)
  end,
  ["tab-switcher:switch-to-last-tab-in-current-split"] = function(items)
    set_active_view(items[1].view)
  end,
})

keymap.add({
  ["alt+p"]       = "tab-switcher:tab-list",
  ["alt+shift+p"] = "tab-switcher:tab-list-current-split"
})

return tab_switcher
