-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local config = require "core.config"


config.plugins.openselected = {}
if PLATFORM == "Windows" then
  config.plugins.openselected.filemanager = "start"
elseif PLATFORM == "Mac OS X" then
  config.plugins.openselected.filemanager = "open"
else
  config.plugins.openselected.filemanager = "xdg-open"
end


command.add("core.docview", {
  ["open-selected:open-selected"] = function()
    local doc = core.active_view.doc
    if not doc:has_selection() then
      core.error("No text selected")
      return
    end

    local text = doc:get_text(doc:get_selection())

    -- trim whitespace from the ends
    text = text:match( "^%s*(.-)%s*$" )

    -- non-Windows platforms need the text quoted (%q)
    if PLATFORM ~= "Windows" then
      text = string.format("%q", text)
    end

    core.log("Opening %s...", text)

    system.exec(config.plugins.openselected.filemanager .. " " .. text)
  end,
})


keymap.add { ["ctrl+shift+o"] = "open-selected:open-selected" }

