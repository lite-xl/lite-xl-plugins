local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"


local function f(x, y)
  return x .. "_" .. string.lower(y)
end


local function toggle(symbol)
  if not symbol:match("[a-z]") then
    return
  elseif symbol:match("_") then
    return symbol:gsub("_(.)", string.upper)
  elseif symbol:match("^[a-z]") then
    return symbol:gsub("(.)([A-Z])", f):lower()
  end
end


command.add("core.docview", {
  ["toggle-snake-camel:toggle"] = function()
    core.active_view.doc:replace(function(text)
      return text:gsub("[%w][%w%d_]*", toggle)
    end)
  end,
})

keymap.add {
  ["f6"] = "toggle-snake-camel:toggle",
}
