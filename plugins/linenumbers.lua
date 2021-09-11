-- mod-version:2 -- lite-xl 2.0
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"
local common = require "core.common"
local command = require "core.command"

local draw = DocView.draw_line_gutter
local get_width = DocView.get_gutter_width

function DocView:draw_line_gutter(idx, x, y, width)
  if not config.line_numbers and not config.relative_line_numbers then
    return
  end

  if config.relative_line_numbers then

    local color = style.line_number
    local local_idx = idx
    local align = "right"

    local l1 = self.doc:get_selection(false)
    if idx == l1 then
      color = style.line_number2
      if config.line_numbers then
        align = "center"
      else
        local_idx = 0
      end
    else
      local_idx = math.abs(idx - l1)
    end

    -- Fix for old version (<=1.16)
    if width == nil then
      local gpad = style.padding.x * 2
      local gw = self:get_font():get_width(#self.doc.lines) + gpad
      width = gpad and gw - gpad or gw
    end

    common.draw_text(
      self:get_font(),
      color, local_idx, align,
      x + style.padding.x,
      y + self:get_line_text_y_offset(),
      width,  self:get_line_height()
    )
  else
    draw(self, idx, x, y, width)
  end
end

function DocView:get_gutter_width(...)
  if not config.line_numbers and not config.relative_line_numbers then
    return style.padding.x
  else
    return get_width(self, ...)
  end
end

command.add(nil, {
  ["line-numbers:toggle"]  = function()
    config.line_numbers = not config.line_numbers
  end,

  ["line-numbers:disable"] = function()
    config.line_numbers = false
  end,

  ["line-numbers:enable"]  = function()
    config.line_numbers = true
  end,

  ["relative-line-numbers:toggle"]  = function()
    config.relative_line_numbers = not config.relative_line_numbers
  end,

  ["relative-line-numbers:enable"]  = function()
    config.relative_line_numbers = true
  end,

  ["relative-line-numbers:disable"]  = function()
    config.relative_line_numbers = false
  end
})
