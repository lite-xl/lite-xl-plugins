-- mod-version:3
local core = require "core"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local keymap = require "core.keymap"

config.plugins.lfautoinsert = common.merge({ map = {
  ["{%s*\n"] = "}",
  ["%(%s*\n"] = ")",
  ["%f[[]%[%s*\n"] = "]",
  ["=%s*\n"] = false,
  [":%s*\n"] = false,
  ["->%s*\n"] = false,
  ["^%s*<([^/!][^%s>]*)[^>]*>%s*\n"] = "</$TEXT>",
  ["^%s*{{#([^/][^%s}]*)[^}]*}}%s*\n"] = "{{/$TEXT}}",
  ["/%*%s*\n"] = "*/",
  ["c/c++"] = {
    file_patterns = {
      "%.c$", "%.h$", "%.inl$", "%.cpp$", "%.hpp$",
      "%.cc$", "%.C$", "%.cxx$", "%.c++$", "%.hh$",
      "%.H$", "%.hxx$", "%.h++$"
    },
    map = {
      ["^#if.*\n"] = "#endif",
      ["^#else.*\n"] = "#endif",
    }
  },
  ["lua"] = {
    file_patterns = { "%.lua$", "%.nelua$" },
    map = {
      ["%f[%w]do%s*\n"] = "end",
      ["%f[%w]then%s*\n"] = "end",
      ["%f[%w]else%s*\n"] = "end",
      ["%f[%w]repeat%s*\n"] = "until",
      ["%f[%w]function.*%)%s*\n"] = "end",
      ["%[%[%s*\n"] = "]]"
    }
  },
} }, config.plugins.lfautoinsert)

local function get_autoinsert_map(filename)
  local map = {}
  if not filename then return map end
  for pattern, closing in pairs(config.plugins.lfautoinsert.map) do
    if type(closing) == "table" then
      if common.match_pattern(filename, closing.file_patterns) then
        for p, e in pairs(closing.map) do
          map[p] = e
        end
      end
    else
      map[pattern] = closing
    end
  end

  return map
end


local function indent_size(doc, line)
  local text = doc.lines[line] or ""
  local s, e = text:find("^[\t ]*")
  return e - s
end

command.add("core.docview!", {
  ["autoinsert:newline"] = function(dv)
    local not_applied =  { }
    local fallback = true
    local doc = dv.doc
    local indent_type, soft_size = doc:get_indent_info()
    local indent_string = indent_type == "hard" and "\t" or string.rep(" ", soft_size)

    for idx, line, col, _, _ in doc:get_selections(true, true) do
      -- We need to add `\n` to keep compatibility with the patterns
      -- that expected a newline to be placed where the caret is.
      local text = doc.lines[line]:sub(1, col - 1) .. '\n'
      local remainder = doc.lines[line]:sub(col, -1)
      local line_indent_size = indent_size(doc, line)
      -- Add more lines to remainder to detect `close`
      for i=line+1,#doc.lines do
        -- Stop adding when we find a line with a different indent level
        if #doc.lines[i] > 1 and indent_size(doc, i) ~= line_indent_size then break end
        remainder = remainder .. doc.lines[i]
        -- Continue adding until the first non-empty line
        if string.find(doc.lines[i], "%S") then
          break
        end
      end
      local current_indent = text:match("^[\t ]*")

      local pre, post
      for ptn, close in pairs(get_autoinsert_map(doc.filename)) do
        local s, _, str = text:find(ptn)
        if s then
          pre = string.format("\n%s%s", current_indent, indent_string)
          if not close then break end
          close = str and close:gsub("$TEXT", str) or close
          if (col == #doc.lines[line] and indent_size(doc, line + 1) <= line_indent_size) or
             (col < #doc.lines[line])
          then
            local clean_remainder = remainder:match("%s*(.*)")
            -- Avoid inserting `close` if it's already present
            local already_closed = clean_remainder:find(close, 1, true) == 1
            if not already_closed and col == #doc.lines[line] then
              -- Add the `close` only if we're at the end of the line
              post = string.format("\n%s%s", current_indent, close)
            elseif already_closed and col < #doc.lines[line] then
              -- Indent the already present `close`
              -- TODO: cleanup the spaces between the caret and the `close`
              post = string.format("\n%s", current_indent)
            end
          end
          break
        end
      end

      if pre or post then
        fallback = false
        doc:text_input(pre or "", idx)
        local l, c, l2, c2 = doc:get_selection_idx(idx)
        doc:text_input(post or "", idx)
        doc:set_selections(idx, l, c, l2, c2)
      else
        table.insert(not_applied, {idx, current_indent})
      end
    end

    -- Only call the fallback if no autoinsert was applied
    if fallback then
      command.perform("doc:newline")
    else
      for _,v in ipairs(not_applied) do
        local idx, indent = table.unpack(v)
        doc:text_input("\n"..indent, idx)
      end
    end
  end
})

keymap.add {
  ["return"] = { "autoinsert:newline" }
}

return {
  add = function(file_patterns, map)
    table.insert(
      config.plugins.lfautoinsert.map,
      { file_patterns = file_patterns, map=map }
    )
  end
}
