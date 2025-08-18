-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require "core.common"
local DocView = require "core.docview"

local nodes_visit_order = setmetatable({}, {__mode = "k"})

---When true, releasing all the modifier keys will accept the selection
local hold_mode = false
---Whether or not the CommandView relative to this plugin is active
local in_switcher = false

---@param t table<any, boolean?>
---@return boolean
local function any_true(t)
  for _, v in pairs(t) do
    if v then return true end
  end
  return false
end

-- We need to override keymap.on_key_released to detect that all the modifier
-- keys were released while in "hold" mode, to accept the current selection.
local old_keymap_on_key_released = keymap.on_key_released
function keymap.on_key_released(k)
  -- Check if hold_mode has been triggered erroneously
  if hold_mode and not in_switcher then
    hold_mode = false
    core.warn("Something went wrong with the tab_switcher plugin. " ..
              "Please open an issue about it in the plugins repository on Github.")
  end

  local was_pressed = any_true(keymap.modkeys)
  old_keymap_on_key_released(k)
  local still_pressed = any_true(keymap.modkeys)

  if hold_mode and was_pressed and not still_pressed then
    hold_mode = false
    command.perform("command:submit")
  end
end


local order_counter = 0

local core_set_active_view = core.set_active_view
function core.set_active_view(view)
  nodes_visit_order[view] = order_counter
  order_counter = order_counter + 1
  return core_set_active_view(view)
end

local tab_switcher = {}

---@class tab_switcher.tab_item
---@field text string The tab name
---@field view core.view

---Returns the list of DocView tabs under a specific node tree.
---@param base_node core.node Where to start the search from
---@return tab_switcher.tab_item[]
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
  return list
end

local function set_active_view(view)
  local n = core.root_view.root_node:get_node_for_view(view)
  if n then n:set_active_view(view) end
end

---@param label string
---@param items tab_switcher.tab_item[]
local function ask_selection(label, items)
  in_switcher = true
  core.command_view:enter(label, {
    submit = function(_, item)
      in_switcher = false
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
    end,
    cancel = function()
      in_switcher = false
    end,
  })
end

command.add(function(items)
    items = items or tab_switcher.get_tab_list(core.root_view.root_node)
    return #items > 0, items
  end, {
  ["tab-switcher:tab-list"] = function(items)
    ask_selection("Switch to tab", items)
  end,
  ["tab-switcher:switch-to-last-tab"] = function(items)
    command.perform("tab-switcher:tab-list", items)
    command.perform("tab-switcher:previous-tab")
  end,
})

command.add(function(items)
    items = items or tab_switcher.get_tab_list(core.root_view:get_active_node())
    return #items > 0, items
  end, {
  ["tab-switcher:tab-list-current-split"] = function(items)
    ask_selection("Switch to tab in current split", items)
  end,
  ["tab-switcher:switch-to-last-tab-in-current-split"] = function(items)
    command.perform("tab-switcher:tab-list-current-split", items)
    command.perform("tab-switcher:previous-tab")
  end,
})

command.add(function() return in_switcher end, {
  ["tab-switcher:next-tab"] = function()
    hold_mode = true
    command.perform("command:select-next")
  end,
  ["tab-switcher:previous-tab"] = function()
    hold_mode = true
    command.perform("command:select-previous")
  end,
})

keymap.add({
  ["alt+p"]             = { "tab-switcher:previous-tab", "tab-switcher:tab-list" },
  ["ctrl+alt+p"]        = { "tab-switcher:previous-tab", "tab-switcher:switch-to-last-tab" },
  ["alt+shift+p"]       = { "tab-switcher:next-tab", "tab-switcher:tab-list-current-split" },
  ["ctrl+alt+shift+p"]  = { "tab-switcher:next-tab", "tab-switcher:switch-to-last-tab-in-current-split" },
})

return tab_switcher
