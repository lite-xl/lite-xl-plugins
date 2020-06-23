local core = require "core"
local config = require "core.config"
local command = require "core.command"

--[[
Date and time format placeholders
from https://www.lua.org/pil/22.1.html
%a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%M	minute (48) [00-59]
%m	month (09) [01-12]
%p	either "am" or "pm" (pm)
%S	second (10) [00-61]
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character `%´
--]]
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

