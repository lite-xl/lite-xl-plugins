local core = require "core"
local command = require "core.command"

local function split_lines(text)
  local res = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    table.insert(res, line)
  end
  return res
end

command.add("core.docview", {
  ["sort:sort"] = function()
    core.active_view.doc:replace(function(text)
      local head, body, foot = text:match("(\n*)(.-)(\n*)$")
      local lines = split_lines(body)
      table.sort(lines, function(a, b) return a:lower() < b:lower() end)
      return head .. table.concat(lines, "\n") .. foot
    end)
  end,
})

