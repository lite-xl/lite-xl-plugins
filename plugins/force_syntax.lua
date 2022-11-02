-- mod-version:3
local core = require "core"
local Doc = require "core.doc"
local syntax = require "core.syntax"
local command = require "core.command"
local common = require "core.common"
local style = require "core.style"
local StatusView = require "core.statusview"
local DocView = require "core.docview"

local function get_doc()
  if core.active_view then return core.active_view:is(DocView), core.active_view.doc end
  if core.last_active_view then return core.last_active_view:is(DocView), core.last_active_view.doc end
end

-- Force plaintext syntax to have a name
local plain_text_syntax = syntax.get("", "")
plain_text_syntax.name = plain_text_syntax.name or "Plain Text"

local doc_reset_syntax = Doc.reset_syntax
function Doc:reset_syntax()
  local syntax_get = syntax.get
  if self.force_syntax then
    syntax.get = function() return self.force_syntax end
  end
  doc_reset_syntax(self)
  syntax.get = syntax_get
end

local function get_syntax_name(s)
  if not s then return "Undefined" end
  local name = s.name
  if not name then
    local exts = type(s.files) == "string" and { s.files } or s.files
    if exts then
      name = table.concat(exts, ", ")
    end
  end
  return name or "Undefined"
end

core.status_view:add_item({
  predicate = get_doc,
  name = "doc:syntax",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    local _, doc = get_doc()
    local syntax_name = get_syntax_name(doc.syntax)
    return {
      style.text,
      syntax_name
    }
  end,
  command = "force-syntax:select-file-syntax",
  position = -1,
  tooltip = "file syntax",
  separator = core.status_view.separator2
})

local function get_syntax_list(doc)
  local pt_name = plain_text_syntax.name
  if doc.syntax == plain_text_syntax then
    pt_name = "Current: "..pt_name
  end
  local list = { ["Auto detect"] = false,
                 [pt_name] = plain_text_syntax }
  local keylist = { "Auto detect", pt_name }

  for _,s in pairs(syntax.items) do
    local name = get_syntax_name(s)
    local fullname = name
    local i = 1
    while list[fullname] do
      i = i + 1
      fullname = name.." ("..i..")"
    end
    if doc.syntax == s then
      fullname = "Current: "..fullname
    end
    list[fullname] = s
    table.insert(keylist, fullname)
  end

  return list, keylist
end

local function sorter(a, b)
  -- Compare only syntax name
  a = a:gsub("Current: ", "")
  b = b:gsub("Current: ", "")
  return string.upper(a) < string.upper(b)
end

local function bias_sorter(a, b)
  -- Bias towards Current and Auto detect syntax
  if a:match("Current: ") then return true end
  if b:match("Current: ") then return false end
  if a:match("Auto detect") then return true end
  if b:match("Auto detect") then return false end
  return sorter(a, b)
end

command.add(get_doc, {
  ["force-syntax:select-file-syntax"] =
    function(doc)
      core.command_view:enter("Set syntax for this file", {
        submit = function(text, item)
          local list, _ = get_syntax_list(doc)
          doc.force_syntax = list[item.text]
          doc:reset_syntax()
        end,
        suggest = function(text)
          local _, keylist = get_syntax_list(doc)
          local res = common.fuzzy_match(keylist, text)
          -- Force Current and Auto detect syntax to the bottom
          -- if the text is empty
          table.sort(res, #text == 0 and bias_sorter or sorter)
          return res
        end
      })
    end
})
