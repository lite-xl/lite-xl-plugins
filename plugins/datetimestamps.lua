local core = require "core"
local config = require "core.config"
local command = require "core.command"

config.datetimestamps_format_datestamp = "%Y%m%d"
config.datetimestamps_format_datetimestamp = "%Y%m%d_%H%M%S"
config.datetimestamps_format_timestamp = "%H%M%S"

local function datestamp()

  local sOut = os.date(config.datetimestamps_format_datestamp)

  core.active_view.doc:text_input(sOut)

end

local function datetimestamp()

  local sOut = os.date(config.datetimestamps_format_datetimestamp)

  core.active_view.doc:text_input(sOut)

end

local function timestamp()

  local sOut = os.date(config.datetimestamps_format_timestamp)

  core.active_view.doc:text_input(sOut)

end

command.add("core.docview", {
  ["datetimestamps:insert-datestamp"] = datestamp,
  ["datetimestamps:insert-timestamp"] = timestamp,
  ["datetimestamps:insert-datetimestamp"] = datetimestamp
})

