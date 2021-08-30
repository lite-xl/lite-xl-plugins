-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"

local function doc()
  return core.active_view.doc
end

local line_in_clipboard = false

local doc_copy = command.map["doc:copy"].perform
command.map["doc:copy"].perform = function()
  if doc():has_selection() then
    doc_copy()
    line_in_clipboard = false
  else
    local line = doc():get_selection()
    system.set_clipboard(doc().lines[line])
    line_in_clipboard = true
  end
end

local doc_cut = command.map["doc:cut"].perform
command.map["doc:cut"].perform = function()
  if doc():has_selection() then
    doc_cut()
    line_in_clipboard = false
  else
    local line = doc():get_selection()
    system.set_clipboard(doc().lines[line])
    if line < #(doc().lines) then
      doc():remove(line, 1, line+1, 1)
    else -- last line in file
      doc():remove(line, 1, line, #(doc().lines[line]))
    end
    doc():set_selection(line, 1)
    line_in_clipboard = true
  end
end

local doc_paste = command.map["doc:paste"].perform
command.map["doc:paste"].perform = function()
  if line_in_clipboard == false then
    doc_paste()
  else
    local line, col = doc():get_selection()
    doc():insert(line, 1, system.get_clipboard():gsub("\r", ""))
    doc():set_selection(line+1, col)
  end
end
