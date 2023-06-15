-- mod-version:3
local core = require "core"
local Doc = require "core.doc"
local command = require "core.command"
local keymap = require "core.keymap"
local config = require "core.config"
local common = require "core.common"

local function string_to_cmd(s)
  local result = {}
  for match in s:gmatch("%g+") do
    table.insert(result, match)
  end
  return result
end

config.plugins.primary_selection = common.merge({
  command_in = { "xclip", "-in", "-selection", "primary" }, -- Command to use to copy the selection
  command_out = { "xclip", "-out", "-selection", "primary" }, -- Command to use to obtain the selection
  set_cursor = true, -- Set cursor on middle mouse click
  min_copy_time = 0.150, -- How much time to delay setting the selection; in seconds
  config_spec = {
    name = "Primary selection",
    {
      label = "Command copy",
      description = "Command to use to copy the selection.",
      path = "_command_in",
      type = "string",
      default = "xclip -in -selection primary",
      on_apply = function(value)
        config.plugins.primary_selection.command_in = string_to_cmd(value)
      end,
    },
    {
      label = "Command paste",
      description = "Command to use to obtain the selection.",
      path = "_command_out",
      type = "string",
      default = "xclip -out -selection primary",
      on_apply = function(value)
        config.plugins.primary_selection.command_out = string_to_cmd(value)
      end,
    },
    {
      label = "Set cursor",
      description = "Set cursor on middle mouse click.",
      path = "set_cursor",
      type = "toggle",
      default = true,
    },
    {
      label = "Copy timeout",
      description = "How much time to delay setting the selection; in milliseconds.",
      path = "min_copy_time_ms",
      type = "number",
      default = 150,
      min = 0,
      step = 50,
      on_apply = function(value)
        config.plugins.primary_selection.min_copy_time = value / 1000
      end
    },
  }
}, config.plugins.primary_selection)


local last_selection_data
--[[
 = {
  time = nil,
  line1 = nil,
  col1 = nil,
  line2 = nil,
  col2 = nil,
  doc = nil,
}
]]

local xclip_copy
local function delayed_copy()
  while true do
    local data = last_selection_data
    if not data then return end
    local current_time = system.get_time()
    local diff_time = current_time - data.time
    -- Check if enough time has passed since last selection change
    if diff_time >= config.plugins.primary_selection.min_copy_time then
      if xclip_copy then xclip_copy:terminate() end
      if not config.plugins.primary_selection.command_in
       or #config.plugins.primary_selection.command_in == 0 then
        core.warn("No primary selection copy command set")
        break
      end
      xclip_copy = process.start(config.plugins.primary_selection.command_in)
      if not xclip_copy then
        core.warn("Unable to start copy command")
        break
      end
      local text = data.doc:get_text(data.line1, data.col1, data.line2, data.col2)
      local nbytes = #text
      local total_written = 0
      -- In some rare cases xclip isn't fast enough so we need to retry sending the data
      local retry = 3
      repeat
        local written, err = xclip_copy:write(text)
        if written == 0 or not written then
          if retry > 0 then
            retry = retry - 1
            coroutine.yield(((3-retry) ^ 2) * 0.05)
          else
            core.error("Error while setting primary selection. "..(err or ""))
            break
          end
        else
          retry = 3
        end
        total_written = total_written + written
        text = string.sub(text, written + 1)
      until total_written >= nbytes
      xclip_copy:close_stream(process.STREAM_STDIN)
      -- We need to leave the process running as killing it would destroy the copied buffer
      break
    end
    coroutine.yield()
  end
  last_selection_data = nil
end


local doc_set_selections = Doc.set_selections
function Doc:set_selections(...)
  local result = doc_set_selections(self, ...)
  local line1, col1, line2, col2
  line1, col1, line2, col2 = self:get_selection()
  if line1 ~= line2 or col1 ~= col2 then
    if not last_selection_data then
      -- Start "timer" to confirm the selection only after `min_copy_time` has passed
      core.add_thread(delayed_copy)
      last_selection_data = { }
    end
    -- We could extract the text here, but it is a potentially heavy operation,
    -- so we do it only when we're actually confirming the selection.
    -- The drawback is that if the selection is overwritten/deleted,
    -- it is either never sent, or is different than expected.
    -- TODO: Confirm the selection on text change.
    last_selection_data.time  = system.get_time()
    last_selection_data.line1 = line1
    last_selection_data.col1  = col1
    last_selection_data.line2 = line2
    last_selection_data.col2  = col2
    last_selection_data.doc   = self
  end
  return result
end


command.add("core.docview", {
  ["primary-selection:paste"] = function(dv, x, y, clicks, ...)
    if not config.plugins.primary_selection.command_out
     or #config.plugins.primary_selection.command_out == 0 then
      core.warn("No primary selection paste command set")
      return
    end
    if x and config.plugins.primary_selection.set_cursor then
      -- TODO: There must be a better way to do this
      core.on_event("mousepressed", "left", x, y, clicks, ...)
      core.on_event("mousereleased", "left", x, y, clicks, ...)
    end
    local xclip = process.start(config.plugins.primary_selection.command_out)
    if not xclip then
      core.warn("Unable to start paste command")
      return
    end
    local text = {}
    repeat
      local buffer = xclip:read_stdout()
      table.insert(text, buffer or "")
    until not buffer
    if #text > 0 then
      dv.doc:text_input(table.concat(text))
    end
  end
})

keymap.add({
  ["1mclick"] = "primary-selection:paste"
})

