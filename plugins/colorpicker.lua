-- mod-version:3
local command = require "core.command"
local keymap = require "core.keymap"
local ColorPickerDialog = require "libraries.widget.colorpickerdialog"

---Get the color format of given text.
---@param text string
---@return "html" | "html_opacity" | "rgb"
local function get_color_type(text)
  local found = text:find("#%x%x%x%x%x%x%x?%x?")
  if found then
    found = text:find("#%x%x%x%x%x%x%x%x")
    if found then return "html_opacity" end
    return "html"
  else
    found = text:find("#%x%x%x")
    if found then
      return "html"
    else
      found = text:find(
        "rgba?%((%d+)%D+(%d+)%D+(%d+)[%s,]-([%.%d]-)%s-%)"
      )
      if found then return "rgb" end
    end
  end
  return "html"
end

command.add("core.docview!", {
  ["color-picker:open"] = function(dv)
    ---@type core.doc
    local doc = dv.doc
    local selection = doc:get_text(doc:get_selection())
    local type = get_color_type(selection)

    ---@type widget.colorpickerdialog
    local picker = ColorPickerDialog(nil, selection)
    function picker:on_apply(c)
      local value
      if type == "html" then
        value = string.format("#%02X%02X%02X", c[1], c[2], c[3])
      elseif type == "html_opacity" then
        value = string.format("#%02X%02X%02X%02X", c[1], c[2], c[3], c[4])
      elseif type == "rgb" then
        value = string.format("rgba(%d, %d, %d, %.2f)", c[1], c[2], c[3], c[4]/255)
      end
      doc:text_input(value)
    end
    picker:show()
    picker:centered()
  end,
})

keymap.add {
  ["ctrl+alt+k"] = "color-picker:open"
}
