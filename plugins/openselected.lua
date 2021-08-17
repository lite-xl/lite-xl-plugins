-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"


command.add("core.docview", {
  ["open-selected:open-selected"] = function()
    local doc = core.active_view.doc
    if not doc:has_selection() then
      core.error("No text selected")
      return
    end

    local text = doc:get_text(doc:get_selection())
    core.log("Opening \"%s\"...", text)

    if PLATFORM == "Windows" then
      system.exec("start " .. text)
    else
      system.exec(string.format("xdg-open %q", text))
    end
  end,
})


keymap.add { ["ctrl+shift+o"] = "open-selected:open-selected" }
