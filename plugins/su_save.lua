-- mod-version:3 priority:99
local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local Doc = require "core.doc"


-- When pkexec version >= 121 is more widespread,
-- change to "pkexec --keep-cwd cp '%s' '%s'"
local default_command = "pkexec sh -c \"cd $PWD; cp '%s' '%s'\""
config.plugins.su_save = common.merge({
  enabled = true,
  save_command = default_command,
  config_spec = {
    name = "Super User Save",
    {
      label = "Enabled",
      description = "Disable or enable the automatic save as super user.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Save command",
      description = "Command used to save the temporary file (first '%s') over the original file (second '%s').",
      path = "save_command",
      type = "string",
      default = default_command
    },
  }
}, config.plugins.su_save)


local doc_save = Doc.save
local function su_save(doc, filename, abs_filename, ...)
  if not config.plugins.su_save then
    return error("Bad su_save plugin configuration")
  end

  local old_clean_change_id = doc.clean_change_id

  -- Override io.open to check for permission errors
  local io_open = io.open
  local temp_filename, save_location
  local io_open_valid = true
  io.open = function(...)
    -- Only override the first io.open call. Hopefully this works well enough.
    io.open = io_open

    -- In case Doc.save crashes before even getting to the first io.open,
    -- we need to use the original one.
    if not io_open_valid then return io_open(...) end

    local fp, error_msg, error_code = io_open(...)
    -- If there was an access issue with open, save to a temporary file
    if error_code == 13 then -- 13 seems to be EACCES, to verify use `errno -l`
      save_location = select(1, ...)
      temp_filename = core.temp_filename()
      core.log_quiet('Trying to save "%s" as super user using "%s" as temporary file', save_location, temp_filename)
      return io_open(temp_filename, select(2, ...))
    end

    return fp, error_msg, error_code
  end

  -- Call original Doc:save, now with custom io.open
  local ok, result = pcall(doc_save, doc, filename, abs_filename, ...)
  io_open_valid = false

  if temp_filename then
    if ok then
      -- This is using the blocking os.execute to simplify error management
      local success, exit_type, exit_code = os.execute(string.format(config.plugins.su_save.save_command, temp_filename, save_location))
      if not success then
        -- Restore change_id because save failed
        doc.clean_change_id = old_clean_change_id
        -- 126 means "dismissed" for pkexec. TODO: Should this be configurable?
        if exit_type == "exit" and exit_code == 126 then
          return error(string.format('Unable to save "%s" with super user permissions (dismissed)', save_location))
        end
        return error(string.format('Unable to save "%s" with super user permissions (%s code %d)', save_location, exit_type, exit_code))
      end
    end
    os.remove(temp_filename)
  end

  if not ok then
    -- Propagate error
    return error(result)
  end

  return result
end

function Doc:save(...)
  if not (config.plugins.su_save and config.plugins.su_save.enabled) then
    return doc_save(self, ...)
  end
  return su_save(self, ...)
end

command.add("core.docview!", {
  ["su-save:save-as-super-user"] = function(dv)
    su_save(dv.doc)
    core.log('Saved "%s"', dv.doc.filename)
  end
})
