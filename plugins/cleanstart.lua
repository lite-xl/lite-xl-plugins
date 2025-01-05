-- mod-version:3
require 'plugins.treeview' -- load after treeview
local command = require 'core.command'

local close = true
for _, v in ipairs(ARGS) do
  local info = system.get_file_info(v)
  if info and info.type == "dir" then close = false; break end
end

if close then command.perform "treeview:toggle" end
