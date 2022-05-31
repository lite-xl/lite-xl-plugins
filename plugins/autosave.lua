-- mod-version:3
local core = require "core"
local config = require "core.config"
local Doc = require "core.doc"
local command = require "core.command"
local common = require "core.common"
-- this is used to detect the wait time
local last_keypress = os.time()
-- this exists so that we don't end up with multiple copies of the loop running at once
local looping = false
local on_text_change = Doc.on_text_change

config.plugins.autosave = common.merge({
  enabled = true,
  -- the approximate amount of time, in seconds, that it takes to trigger an autosave
  timeout = 1,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Auto Save",
    {
      label = "Enable",
      description = "Enable or disable the auto save feature.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Timeout",
      description = "Approximate amount of time in seconds it takes to trigger an autosave.",
      path = "timeout",
      type = "number",
      default = 1,
      min = 1,
      max = 30
    }
  }
}, config.plugins.autosave)


local function loop_for_save()
    while looping do
      if os.difftime(os.time(), last_keypress) >= config.plugins.autosave.timeout then
        command.perform "doc:save"
        -- stop loop
        looping = false
      end
      -- wait the timeout. may cause timeout to be slightly imprescise
      coroutine.yield(config.plugins.autosave.timeout)
    end
end


local function updatepress()
  -- set last keypress time to now
  last_keypress = os.time()
  -- put loop in coroutine so it doesn't lag out this script
  if not looping then
    looping = true
    core.add_thread(loop_for_save)
  end
end


function Doc:on_text_change(type)
  -- check if file is saved
  if config.plugins.autosave.enabled and self.filename then
    updatepress()
  end
  return on_text_change(self, type)
end
