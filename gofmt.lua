local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"

local function exec(cmd)
  local fp = io.popen(cmd, "r")
  local res = fp:read("*a")
  local success = fp:close()
  return res:gsub("%\n$", ""), success
end

local function get_cmd_text(cmd, doc)
  local active_filename = doc and system.absolute_path(doc.filename or "")
  return exec(string.format("%s %s", cmd, active_filename))
end

local function update_doc(cmd, doc)
  local text, success = get_cmd_text(cmd, doc)
  if success == nil then
    local err_text = "Command '%s' not found in the system"
    core.error(string.format(err_text, cmd))
    return
  end

  local sel = { doc:get_selection() }
  doc:remove(1, 1, math.huge, math.huge)
  doc:insert(1, 1, text)
  doc:set_selection(table.unpack(sel))
end

command.add("core.docview", {
  ["gofmt:gofmt"] = function()
    update_doc("gofmt", core.active_view.doc)
  end,

  ["gofmt:goimports"] = function()
    update_doc("goimports", core.active_view.doc)
  end,

  ["gofmt:goreturns"] = function()
    update_doc("goreturns", core.active_view.doc)
  end,
})

keymap.add {
  ["ctrl+i"] = "gofmt:gofmt",
  ["ctrl+h"] = "gofmt:goimports",
  ["ctrl+u"] = "gofmt:goreturns",
}
