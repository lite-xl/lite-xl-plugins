-- mod-version:3
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"
local common = require "core.common"
local command = require "core.command"

config.plugins.linenumbers = common.merge({
  show = true,
  relative = false,
  hybrid = false,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Line Numbers",
    {
      label = "Show Numbers",
      description = "Display or hide the line numbers.",
      path = "show",
      type = "toggle",
      default = true
    },
    {
      label = "Relative Line Numbers",
      description = "Display relative line numbers starting from active line.",
      path = "relative",
      type = "toggle",
      default = false
    },
    {
      label = "Hybrid Line Numbers",
      description = "Display hybrid line numbers starting from active line (Overpowers relative line-numbers).",
      path = "hybrid",
      type = "toggle",
      default = false
    }
  }
}, config.plugins.linenumbers)

local draw_line_gutter = DocView.draw_line_gutter
local get_gutter_width = DocView.get_gutter_width

function DocView:draw_line_gutter(line, x, y, width)
  local lh = self:get_line_height()
  if not config.plugins.linenumbers.show then
    return lh
  end

  if not (config.plugins.linenumbers.relative or config.plugins.linenumbers.hybrid) then
    return draw_line_gutter(self, line, x, y, width)
  end

  local color = style.line_number

  for _, line1, _, line2 in self.doc:get_selections(true) do
    if line == line1 then
      color = style.line_number2
      break
    end
  end

  local l1 = self.doc:get_selection(false)
  local local_idx = math.abs(line - l1)
  local alignment = "right"
  local x_offset = style.padding.x

  if config.plugins.linenumbers.hybrid and line == l1 then
    local_idx = line
    alignment = "left"
    x_offset = 0
  end

  common.draw_text(
    self:get_font(),
    color, local_idx, alignment,
    x + x_offset,
    y,
    width, lh
  )

  return lh
end

function DocView:get_gutter_width(...)
  if
      not config.plugins.linenumbers.show
  then
    local width = get_gutter_width(self, ...)

    local correct_width = self:get_font():get_width(#self.doc.lines)
        + (style.padding.x * 2)

    -- compatibility with center doc
    if width <= correct_width then
      width = style.padding.x
    end

    return width, 0
  else
    return get_gutter_width(self, ...)
  end
end

command.add(nil, {
  ["line-numbers:toggle"]           = function()
    config.plugins.linenumbers.show = not config.plugins.linenumbers.show
  end,

  ["line-numbers:disable"]          = function()
    config.plugins.linenumbers.show = false
  end,

  ["line-numbers:enable"]           = function()
    config.plugins.linenumbers.show = true
  end,

  ["relative-line-numbers:toggle"]  = function()
    config.plugins.linenumbers.relative = not config.plugins.linenumbers.relative
  end,

  ["relative-line-numbers:enable"]  = function()
    config.plugins.linenumbers.relative = true
  end,

  ["relative-line-numbers:disable"] = function()
    config.plugins.linenumbers.relative = false
  end,

  ["hybrid-line-numbers:toggle"]    = function()
    config.plugins.linenumbers.hybrid = not config.plugins.linenumbers.hybrid
    if config.plugins.linenumbers.hybrid then
      config.plugins.linenumbers.relative = false -- Disable relative mode when enabling hybrid mode
    end
  end,

  ["hybrid-line-numbers:enable"]    = function()
    config.plugins.linenumbers.hybrid = true
    config.plugins.linenumbers.relative = false
  end,

  ["hybrid-line-numbers:disable"]   = function()
    config.plugins.linenumbers.hybrid = false
  end
})
