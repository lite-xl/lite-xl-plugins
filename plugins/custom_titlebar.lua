--- mod-version:3
local core = require "core"
local DocView = require "core.docview"
local config = require "core.config"
local common = require "core.common"

-- Customize the Lite XL title bar.

config.plugins.custom_titlebar = common.merge({
  -- The title bar format, available variables are:
  --  $filepath - Path to the current open file.
  --  $dirpath - Path to the project directory.
  --  $projectname - The Proejct name.
  --  $savestatus - Wether the Open file is saved or not.
  -- You can choose any aribrary string and/or use the provided variables.
  title_format = "$filepath $savestatus - Lite XL",
  config_spec = {
    name = "Custom Title Bar",
    {
      label = "Format",
      description = "Define how you want the title bar to be formatted, available variables are: $filepath, $dirpath and/or $projectname.",
      path = "title_format",
      type = "string",
      default = "$filepath - Lite XL"
    },
  }
}, config.plugins.custom_titlebar)

-- Stolen from core
local function get_title_filename(view)
  local doc_filename = view.get_filename and view:get_filename() or view:get_name()
  if doc_filename ~= "---" then return doc_filename end
  return ""
end


local project_dir = core.recent_projects[1] or "."

local filepath = get_title_filename(core.active_view)
local dirpath, projectname = system.absolute_path(project_dir):match("(.*)[/\\\\](.*)")

local titlebar_format = config.plugins.custom_titlebar.title_format

if titlebar_format ~= nil and titlebar_format ~= "" then
  -- $filepath, $dirpath, $projectname, $litexl
  titlebar_format = string.gsub(titlebar_format, "$filepath", filepath)
  titlebar_format = string.gsub(titlebar_format, "$dirpath", dirpath)
  titlebar_format = string.gsub(titlebar_format, "$projectname", projectname)
end

if titlebar_format ~= nil and titlebar_format ~= "" then
    system.set_window_title(titlebar_format)
    core.window_title = titlebar_format
end

