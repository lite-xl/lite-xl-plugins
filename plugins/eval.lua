-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local config = require "core.config"


local function eval(str)
  local fn, err = load("return " .. str)
  if not fn then fn, err = load(str) end
  assert(fn, err)
  return tostring(fn())
end


command.add("core.docview", {
  ["eval:insert"] = function(dv)
    core.command_view:enter("Evaluate And Insert Result", {
      submit = function(cmd)
        dv.doc:text_input(eval(cmd))
      end
    })
  end,

  ["eval:replace"] = function(dv)
    core.command_view:enter("Evaluate And Replace With Result", {
      submit = function(cmd)
        dv.doc:replace(function(str)
          return eval(cmd)
        end)
      end
    })
  end,

  ["eval:selected"] = function(dv)
    if dv.doc:has_selection() then
      local text = dv.doc:get_text(dv.doc:get_selection())
      dv.doc:text_input(eval(text))
    else
      local line = dv.doc:get_selection()
      local text = dv.doc.lines[line]
      dv.doc:insert(line+1, 0, "= " .. eval(text) .. "\n")
    end
  end,
})

-- defer adding context menu item until all plugins have had
-- a chance to turn it off/on
local function add_context_menu()
  if false == config.plugins.contextmenu then return end

  -- abort if contextmenu plugin isn't available
  local found, contextmenu = pcall(require, "plugins.contextmenu")
  if not found then
    core.log("[eval] no plugin.contextmenu, not adding context menu item.")
    return
  end

  contextmenu:register("core.docview", {
    { text = "Evaluate Selected",  command = "eval:selected" }
  })
end
-- Add context menu item after everything has been loaded
core.add_thread(add_context_menu)


keymap.add { ["ctrl+alt+return"] = "eval:selected" }
