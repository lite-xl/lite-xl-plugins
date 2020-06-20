local core = require "core"
local command = require "core.command"

local function datestamp()

  local sOut = os.date('%Y%m%d')

  core.active_view.doc:text_input(sOut)

end

local function datetimestamp()

  local sOut = os.date('%Y%m%d_%H%M%S')

  core.active_view.doc:text_input(sOut)

end

local function timestamp()

  local sOut = os.date('%H%M%S')

  core.active_view.doc:text_input(sOut)

end

command.add("core.docview", {
  ["datetimestamps:datestamp"] = datestamp,
  ["datetimestamps:timestamp"] = timestamp,
  ["datetimestamps:datetimestamp"] = datetimestamp
})

