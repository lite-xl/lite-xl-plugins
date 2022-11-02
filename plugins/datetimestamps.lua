-- mod-version:3
local core = require "core"
local config = require "core.config"
local command = require "core.command"
local common = require "core.common"

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
config.plugins.datetimestamps = common.merge({
  format_datestamp = "%Y%m%d",
  format_datetimestamp = "%Y%m%d_%H%M%S",
  format_timestamp = "%H%M%S",
  -- The config specification used by the settings gui
  config_spec = {
    name = "Date and Time Stamps",
    {
      label = "Date",
      description = "Date specification defined with Lua date/time place holders.",
      path = "format_datestamp",
      type = "string",
      default = "%Y%m%d"
    },
    {
      label = "Time",
      description = "Time specification defined with Lua date/time place holders.",
      path = "format_timestamp",
      type = "string",
      default = "%H%M%S"
    },
    {
      label = "Date and Time",
      description = "Date and time specification defined with Lua date/time place holders.",
      path = "format_datetimestamp",
      type = "string",
      default = "%Y%m%d_%H%M%S"
    }
  }
}, config.plugins.datetimestamps)

local function datestamp(dv)
  local sOut = os.date(config.plugins.datetimestamps.format_datestamp)
  dv.doc:text_input(sOut)
end

local function datetimestamp(dv)
  local sOut = os.date(config.plugins.datetimestamps.format_datetimestamp)
  dv.doc:text_input(sOut)
end

local function timestamp(dv)
  local sOut = os.date(config.plugins.datetimestamps.format_timestamp)
  dv.doc:text_input(sOut)
end

command.add("core.docview", {
  ["datetimestamps:insert-datestamp"] = datestamp,
  ["datetimestamps:insert-timestamp"] = timestamp,
  ["datetimestamps:insert-datetimestamp"] = datetimestamp,
  ["datetimestamps:insert-custom"] = function(dv)
    core.command_view:enter("Date format eg: %H:%M:%S", {
      submit = function(cmd)
        dv.doc:text_input(os.date(cmd) or "")
      end
    })
  end,
})

