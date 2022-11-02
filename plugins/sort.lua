-- mod-version:3
local core = require "core"
local command = require "core.command"
local translate = require "core.doc.translate"

-- Workaround for bug in Lite XL 2.1
-- Remove this when b029f5993edb7dee5ccd2ba55faac1ec22e24609 is in a release
local function get_selection(doc, sort)
  local line1, col1, line2, col2 = doc:get_selection_idx(doc.last_selection)
  if line1 then
    return doc:get_selection_idx(doc.last_selection, sort)
  else
    return doc:get_selection_idx(1, sort)
  end
end

local function split_lines(text)
  local res = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    table.insert(res, line)
  end
  return res
end

command.add("core.docview!", {
  ["sort:sort"] = function(dv)
    local doc = dv.doc

    local l1, c1, l2, c2, swap = get_selection(doc, true)
    l1, c1 = translate.start_of_line(doc, l1, c1)
    l2, c2 = translate.end_of_line(doc, l2, c2)
    doc:set_selection(l1, c1, l2, c2, swap)

    doc:replace(function(text)
      local head, body, foot = text:match("(\n*)(.-)(\n*)$")
      local lines = split_lines(body)
      table.sort(lines, function(a, b) return a:lower() < b:lower() end)
      return head .. table.concat(lines, "\n") .. foot, 1
    end)
  end,
})

