-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require "core.common"
local config = require "core.config"
local contextmenu = require "plugins.contextmenu"


local platform_filelauncher
if PLATFORM == "Windows" then
  platform_filelauncher = "start"
elseif PLATFORM == "Mac OS X" then
  platform_filelauncher = "open"
else
  platform_filelauncher = "xdg-open"
end

config.plugins.openselected = common.merge({
  filelauncher = platform_filelauncher,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Open Selected Text",
    {
      label = "File Launcher",
      description = "Command used to open the selected path or link externally.",
      path = "filelauncher",
      type = "string",
      default = platform_filelauncher
    }
  }
}, config.plugins.openselected)

local function select_word_under_cursor(doc)
  local line, col = doc:get_selection() -- will be cursor if no selection
  local text = doc.lines[line]
  local pattern = "%s'\""

  if not text or text == "\n" then return nil end

  local start_col = text:sub(1,col):find("[^"..pattern.."]")
  local end_col = col + text:sub(col, #text):find("["..pattern.."]") - 1
  doc:set_selection(line, end_col, line, start_col)
  return doc:get_text(doc:get_selection())
end

command.add("core.docview!", {
  ["open-selected:open-selected"] = function(dv)
    local doc = dv.doc
    local text

    if not doc:has_selection() then
      text = select_word_under_cursor(doc)
      if not text or text == "" then
        core.error("No text found at cursor")
        return
      end
    else
      text = doc:get_text(doc:get_selection())
    end

    -- trim whitespace from the ends
    text = text:match( "^%s*(.-)%s*$" )

    -- non-Windows platforms need the text quoted (%q)
    if PLATFORM ~= "Windows" then
      text = string.format("%q", text)
    end

    core.log("Opening %s...", text)

    system.exec(config.plugins.openselected.filelauncher .. " " .. text)
  end,
})


contextmenu:register("core.docview", {
  contextmenu.DIVIDER,
  { text = "Open Selection",  command = "open-selected:open-selected" }
})


keymap.add { ["ctrl+alt+o"] = "open-selected:open-selected" }
