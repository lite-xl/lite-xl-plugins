-- mod-version:3 --priority:0

local core = require "core"
local common = require "core.common"
local config = require "core.config"
local command = require "core.command"
local profiler = require "plugins.profiler.profiler"

--Keep track of profiler status.
local RUNNING = false
--The profiler runs before the settings plugin, we need to manually load them.
local SETTINGS_PATH = USERDIR .. PATHSEP .. "user_settings.lua"
-- Default location to store the profiler results.
local DEFAULT_LOG_PATH = USERDIR .. PATHSEP .. "profiler.log"

config.plugins.profiler = common.merge({
  enable_on_startup = false,
  log_file = DEFAULT_LOG_PATH,
  config_spec = {
    name = "Profiler",
    {
      label = "Enable on Startup",
      description = "Enable profiler early on plugin startup process.",
      path = "enable_on_startup",
      type = "toggle",
      default = false
    },
    {
      label = "Log Path",
      description = "Path to the file that will contain the profiler logged data.",
      path = "log_file",
      type = "file",
      default = DEFAULT_LOG_PATH,
      filters = {"%.log$"}
    }
  }
}, config.plugins.profiler)

---@class plugins.profiler
local Profiler = {}

function Profiler.start()
  if RUNNING then return end
  profiler.start()
  RUNNING = true
end

function Profiler.stop()
  if RUNNING then
    profiler.stop()
    profiler.report(config.plugins.profiler.log_file)
    RUNNING = false
  end
end

--------------------------------------------------------------------------------
-- Run profiler at startup if enabled.
--------------------------------------------------------------------------------
if system.get_file_info(SETTINGS_PATH) then
  local ok, t = pcall(dofile, SETTINGS_PATH)
  if ok and t.config and t.config.plugins and t.config.plugins.profiler then
    local options = t.config.plugins.profiler
    local profiler_ref = config.plugins.profiler
    profiler_ref.enable_on_startup = options.enable_on_startup or false
    profiler_ref.log_file = options.log_file or DEFAULT_LOG_PATH
  end
end

if config.plugins.profiler.enable_on_startup then
  Profiler.start()
end

--------------------------------------------------------------------------------
-- Override core.run to stop profiler before exit if running.
--------------------------------------------------------------------------------
local core_run = core.run
function core.run(...)
  core_run(...)
  Profiler.stop()
end

--------------------------------------------------------------------------------
-- Add a profiler toggle command.
--------------------------------------------------------------------------------
command.add(nil, {
  ["profiler:toggle"] = function()
    if RUNNING then
      Profiler.stop()
      core.log("Profiler: stopped")
      core.root_view:open_doc(core.open_doc(config.plugins.profiler.log_file))
    else
      Profiler.start()
      core.log("Profiler: started")
    end
  end
})


return Profiler
