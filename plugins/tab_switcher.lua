-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require "core.common"
local DocView = require "core.docview"

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
  return list
end

local function ask_selection(label, items)
  if #items == 0 then
    core.warn("No tabs available")
    return
  end
  core.command_view:enter(label, {
    submit = function(_, item)
      local n = core.root_view.root_node:get_node_for_view(item.view)
      if n then n:set_active_view(item.view) end
    end,
    suggest = function(text)
      return common.fuzzy_match(items, text, true)
    end,
    validate = function(_, item)
      return item
    end
  })
end

command.add(nil,{
  ["tab-switcher:tab-list"] = function()
    ask_selection("Switch to tab", tab_switcher.get_tab_list(core.root_view.root_node))
  end,
  ["tab-switcher:tab-list-current-split"] = function()
    ask_selection("Switch to tab in current split", tab_switcher.get_tab_list(core.root_view:get_active_node()))
  end
})

keymap.add({
  ["alt+p"]       = "tab-switcher:tab-list",
  ["alt+shift+p"] = "tab-switcher:tab-list-current-split"
})

return tab_switcher
