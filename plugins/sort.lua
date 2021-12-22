-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"
local translate = require "core.doc.translate"

local function adjust_selection(doc)
    local l1, c1, l2, c2, swap = doc:get_selection(true)
    l1, c1 = translate.start_of_line(doc, l1, c1)
    l2, c2 = translate.end_of_line(doc, l2, c2)
    doc:set_selection(l1, c1, l2, c2, swap)
end

local function split_lines(text)
    local res = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do table.insert(res, line) end
    return res
end

local function sort_lines(text, fn)
    local head, body, foot = text:match("(\n*)(.-)(\n*)$")
    local lines = split_lines(body)
    table.sort(lines, fn)
    return head .. table.concat(lines, "\n") .. foot, 1
end

local function padnum(d)
    local dec, n = string.match(d, "(%.?)0*(.+)")
    return #dec > 0 and ("%.12f"):format(d) or ("%s%03d%s"):format(dec, #n, n)
end

local function sort_alpha(a, b)
    return a:lower() < b:lower()
end

local function sort_alpha_desc(a, b)
    return a:lower() > b:lower()
end

local function sort_natural(a, b, reverse)
    local a1 = a:gsub("%.?%d+", padnum) .. ("%3d"):format(#b)
    local b1 = b:gsub("%.?%d+", padnum) .. ("%3d"):format(#a)
    if reverse then
        return a1 > b1
    else
        return a1 < b1
    end
end

local function do_sort(fn)
    local doc = core.active_view.doc
    adjust_selection(doc)
    doc:replace(function(text) return sort_lines(text, fn) end)
end

command.add("core.docview", {
    ["sort:sort-alpha"] = function() do_sort(sort_alpha) end,
    ["sort:sort-alpha-descending"] = function() do_sort(sort_alpha_desc) end,
    ["sort:sort-natural"] = function() do_sort(function(a, b) return sort_natural(a, b, false) end) end,
    ["sort:sort-natural-descending"] = function() do_sort(function(a, b) return sort_natural(a, b, true) end) end
})

