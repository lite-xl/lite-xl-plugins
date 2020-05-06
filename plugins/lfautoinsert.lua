local core = require "core"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"

config.autoinsert_map = {
  ["{\n"] = "}",
  ["%(\n"] = ")",
  ["%f[[]%[\n"] = "]",
  ["%[%[\n"] = "]]",
  ["=\n"] = false,
  [":\n"] = false,
  ["^#if"] = "#endif",
  ["^#else"] = "#endif",
  ["%f[%w]do\n"] = "end",
  ["%f[%w]then\n"] = "end",
  ["%f[%w]else\n"] = "end",
  ["%f[%w]repeat\n"] = "until",
  ["%f[%w]function.*%)\n"] = "end",
}


local function indent_size(doc, line)
  local text = doc.lines[line] or ""
  local s, e = text:find("^[\t ]*")
  return e - s
end

command.add("core.docview", {
  ["autoinsert:newline"] = function()
    local doc = core.active_view.doc
    local line = doc:get_selection()
    local text = doc.lines[line]

    command.perform("doc:newline")

    for ptn, close in pairs(config.autoinsert_map) do
      if text:find(ptn) then
        if  close
        and indent_size(doc, line + 2) <= indent_size(doc, line)
        then
          command.perform("doc:newline")
          core.active_view:on_text_input(close)
          command.perform("doc:move-to-previous-line")
        end
        command.perform("doc:indent")
      end
    end
  end
})

keymap.add {
  ["return"] = { "command:submit", "autoinsert:newline" }
}
