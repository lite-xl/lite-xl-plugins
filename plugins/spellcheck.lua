local core = require "core"
local style = require "core.style"
local config = require "core.config"
local command = require "core.command"
local DocView = require "core.docview"

config.spellcheck_files = { "%.txt$", "%.md$", "%.markdown$" }
config.dictionary_file = "/usr/share/dict/words"

local words

core.add_thread(function()
  local t = {}
  local i = 0
  for line in io.lines(config.dictionary_file) do
    for word in line:gmatch("%a+") do
      t[word:lower()] = true
    end
    i = i + 1
    if i % 1000 == 0 then coroutine.yield() end
  end
  words = t
  core.redraw = true
  core.log_quiet("Finished loading dictionary file: \"%s\"", config.dictionary_file)
end)


local function matches_any(filename, ptns)
  for _, ptn in ipairs(ptns) do
    if filename:find(ptn) then return true end
  end
end


local draw_line_text = DocView.draw_line_text

function DocView:draw_line_text(idx, x, y)
  draw_line_text(self, idx, x, y)

  if not words
  or not matches_any(self.doc.filename or "", config.spellcheck_files) then
    return
  end

  local s, e = 0, 0
  local text = self.doc.lines[idx]
  local l, c = self.doc:get_selection()

  while true do
    s, e = text:find("%a+", e + 1)
    if not s then break end
    local word = text:sub(s, e):lower()
    if not words[word] and not (l == idx and c == e + 1) then
      local color = style.spellcheck_error or style.syntax.keyword2
      local x1 = x + self:get_col_x_offset(idx, s)
      local x2 = x + self:get_col_x_offset(idx, e + 1)
      local h = style.divider_size
      renderer.draw_rect(x1, y + self:get_line_height() - h, x2 - x1, h, color)
    end
  end
end

