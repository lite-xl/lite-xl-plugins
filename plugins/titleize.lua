-- mod-version:3
local core = require "core"
local command = require "core.command"

command.add("core.docview", {
  ["titleize:titleize"] = function(dv)
    dv.doc:replace(function(text)
      return text:gsub("%f[%w](%w)", string.upper)
    end)
  end,
})
