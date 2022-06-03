-- mod-version:3
local core = require "core"
local config = require "core.config"
local command = require "core.command"
local common = require "core.common"
local DocView = require "core.docview"

config.plugins.autowrap = common.merge({
  enabled = false,
  files = { "%.md$", "%.txt$" },
  -- The config specification used by the settings gui
  config_spec = {
    name = "Auto Wrap",
    {
      label = "Enable",
      description = "Activates text auto wrapping by default.",
      path = "enabled",
      type = "toggle",
      default = false
    },
    {
      label = "Files",
      description = "List of Lua patterns matching files to auto wrap.",
      path = "files",
      type = "list_strings",
      default = { "%.md$", "%.txt$" },
    }
  }
}, config.plugins.autowrap)


local on_text_input = DocView.on_text_input

DocView.on_text_input = function(self, ...)
  on_text_input(self, ...)

  if not config.plugins.autowrap.enabled then return end

  -- early-exit if the filename does not match a file type pattern
  local filename = self.doc.filename or ""
  local matched = false
  for _, ptn in ipairs(config.plugins.autowrap.files) do
    if filename:match(ptn) then
      matched = true
      break
    end
  end
  if not matched then return end

  -- do automatic reflow on line if we're typing at the end of the line and have
  -- reached the line limit
  local line, col = self.doc:get_selection()
  local text = self.doc:get_text(line, 1, line, math.huge)
  if #text >= config.line_limit and col > #text then
    command.perform("doc:select-lines")
    command.perform("reflow:reflow")
    command.perform("doc:move-to-next-char")
    command.perform("doc:move-to-end-of-line")
  end
end

command.add(nil, {
  ["auto-wrap:toggle"] = function()
    config.plugins.autowrap.enabled = not config.plugins.autowrap.enabled
    if config.plugins.autowrap.enabled then
      core.log("Auto wrap: on")
    else
      core.log("Auto wrap: off")
    end
  end
})
