-- mod-version:3
local core = require "core"
local command = require "core.command"
local contextmenu = require "plugins.contextmenu"
local keymap = require "core.keymap"


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
    for idx, line1, col1, line2, col2 in dv.doc:get_selections() do
      if line1 ~= line2 or col1 ~= col2 then
        local text = dv.doc:get_text(line1, col1, line2, col2)
        dv.doc:text_input(eval(text), idx)
      else
        local text = dv.doc.lines[line1]
        dv.doc:replace_cursor(idx, line1, 0, line1, #text, eval)
      end
    end
  end,
})


contextmenu:register("core.docview", {
  { text = "Evaluate Selected",  command = "eval:selected" }
})


keymap.add { ["ctrl+alt+return"] = "eval:selected" }
