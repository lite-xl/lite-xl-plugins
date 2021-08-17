-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local keymap = require "core.keymap"
local command = require "core.command"

-- Takes the following pattern: /pattern/replace/
-- Capture groupings can be replaced using \1 through \9
local function regex_replace_file(view, pattern, old_lines, raw, start_line, end_line)
   local doc = view.doc
   local start_pattern, end_pattern, end_replacement, start_replacement = 2, 2;
   repeat 
      end_pattern = string.find(pattern, "/", end_pattern)
   until end_pattern == nil or pattern[end_pattern-1] ~= "\\"
   if end_pattern == nil then
      end_pattern = #pattern + 1
   else
      end_pattern = end_pattern - 1
      start_replacement = end_pattern+2;
      end_replacement = end_pattern+2;
      repeat
         end_replacement = string.find(pattern, "/", end_replacement)
      until end_replacement == nil or pattern[end_replacement-1] ~= "\\"
   end
   end_replacement = end_replacement and (end_replacement - 1)
      
   local re = start_pattern ~= end_pattern and regex.compile(pattern:sub(start_pattern, end_pattern))
   
   local replacement = end_replacement and pattern:sub(start_replacement, end_replacement)
   local replace_line = raw and function(line, new_text)
      if line == #doc.lines then
         doc:raw_remove(line, 1, line, #doc.lines[line], { idx = 1 }, 0)
      else
         doc:raw_remove(line, 1, line+1, 1, { idx = 1 }, 0)
      end
      doc:raw_insert(line, 1, new_text, { idx = 1 }, 0)
   end or function(line, new_text)
      if line == #doc.lines then
         doc:remove(line, 1, line, #doc.lines[line])
      else
         doc:remove(line, 1, line+1, 1)
      end
      doc:insert(line, 1, new_text)
   end
   
   local line_scroll = nil
   if re then
      for i = (start_line or 1), (end_line or #doc.lines) do
         local new_text, matches, rmatches
         local old_text = old_lines[i] or doc.lines[i]
         local old_length = #old_text
         if replacement then
            new_text, matches, rmatches = regex.gsub(re, old_text, replacement)
         end
         if matches and #matches > 0 then
            old_lines[i] = old_text
            replace_line(i, new_text)
            if line_scroll == nil then
               line_scroll = i
               doc:set_selection(i, rmatches[1][1], i, rmatches[1][2])
            end
         elseif old_lines[i] then
            replace_line(i, old_lines[i])
            old_lines[i] = nil
         end
         if not replacement then
            local s,e = regex.match(re, old_text)
            if s then
               line_scroll = i
               doc:set_selection(i, s, i, e)
               break
            end
         end
      end
      if line_scroll then
         view:scroll_to_line(line_scroll, true)
      end
   end
   if replacement == nil then
      for k,v in pairs(old_lines) do
         replace_line(k, v)
      end
      old_lines = {}
   end
   return old_lines, line_scroll ~= nil
end

command.add("core.docview", {
   ["regex-replace-preview:find-replace-regex"] = function()
      core.command_view:set_text("/")
      local old_lines = {}
      local view = core.active_view
      local doc = view.doc
      local original_selection = { doc:get_selection(true) }
      local selection = doc:has_selection() and { doc:get_selection(true) } or {}
      core.command_view:enter(
         "Regex Replace (enter pattern as /old/new/)", 
         function(pattern)
            regex_replace_file(view, pattern, {}, false, selection[1], selection[3])
         end,
         function(pattern)
            local incremental, has_replacement = regex_replace_file(view, pattern, old_lines, true, selection[1], selection[3])
            if incremental then
               old_lines = incremental
            end
            if not has_replacement then
               doc:set_selection(unpack(original_selection))
            end
         end,
         function(pattern)
            for k,v in pairs(old_lines) do
               if v then
                  if k == #doc.lines then
                     doc:raw_remove(k, 1, k, #doc.lines[k], { idx = 1 }, 0)
                  else
                     doc:raw_remove(k, 1, k+1, 1, { idx = 1 }, 0)
                  end
                  doc:raw_insert(k, 1, v, { idx = 1 }, 0)
               end
            end
            doc:set_selection(unpack(original_selection))
         end
      ) 
   end
})

keymap.add { ["ctrl+shift+r"] = "regex-replace-preview:find-replace-regex" }
