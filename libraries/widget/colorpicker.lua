--
-- Color Picker Widget
-- Note: HSV and HSL conversion functions adapted from:
-- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
-- which in turn was ported from:
-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--
local core = require "core"
local style = require "core.style"
local common = require "core.common"
local Widget = require "libraries.widget"
local TextBox = require "libraries.widget.textbox"

---@alias widget.colorpicker.colorrange renderer.color[]

---The numerical portion of a color range on the hue selection bar.
---@type number
local HUE_COLOR_SEGMENT = 100 / 6

---Hue color ranges in the order rendered on the hue bar.
---@type widget.colorpicker.colorrange[]
local HUE_COLOR_RANGES = {
  -- red -> yellow
  { {255, 0, 0, 255}, {255, 255, 0, 255} },
  -- yellow -> green
  { {255, 255, 0, 255}, {0, 255, 0, 255} },
  -- green -> cyan
  { {0, 255 ,0, 255}, {0, 255, 255, 255} },
  -- cyan -> blue
  { {0, 255, 255, 255}, {0, 0, 255, 255} },
  -- blue -> purple
  { {0, 0, 255, 255}, {255, 0, 255, 255} },
  -- purple -> red
  { {255, 0, 255, 255}, {255, 0, 0, 255} }
}

---@type renderer.color
local COLOR_BLACK = {0, 0, 0, 255}

---@type renderer.color
local COLOR_WHITE = {255, 255, 255, 255}

---@class widget.colorpicker : widget
---@field hue_color renderer.color
---@field saturation_color renderer.color
---@field brightness_color renderer.color
---@field hue_pos number
---@field saturation_pos number
---@field brightness_pos number
---@field alpha number
---@field hue_mouse_down boolean
---@field saturation_mouse_down boolean
---@field brightness_mouse_down boolean
---@field html_notation widget.textbox
---@field rgba_notation widget.textbox
local ColorPicker = Widget:extend()

---Constructor
---@param parent widget
---@param color? renderer.color | string
function ColorPicker:new(parent, color)
  ColorPicker.super.new(self, parent, false)

  self.type_name = "widget.colorpicker"

  self.hue_pos = 0
  self.saturation_pos = 100
  self.brightness_pos = 100
  self.alpha = 255

  self.hue_color = COLOR_BLACK
  self.saturation_color = COLOR_BLACK
  self.brightness_color = COLOR_BLACK

  self.hue_mouse_down = false;
  self.saturation_mouse_down = false
  self.brightness_mouse_down = false

  self.selector = { x = 0, y = 0, w = 0, h = 0 }

  local this = self
  self.html_notation = TextBox(self, "#FF0000")
  self.rgba_notation = TextBox(self, "rgba(255,0,0,1)")
  self.html_updating = false
  self.rgba_updating = false

  function self.html_notation:on_change(value)
    if
      not this.hue_mouse_down
      and
      not this.saturation_mouse_down
      and
      not this.brightness_mouse_down
      and
      not this.html_updating
    then
      this:set_color(value, true)
    end
  end

  function self.rgba_notation:on_change(value)
    if
      not this.hue_mouse_down
      and
      not this.saturation_mouse_down
      and
      not this.brightness_mouse_down
      and
      not this.rgba_updating
    then
      this:set_color(value, false, true)
    end
  end

  self:set_border_width(0)

  self:set_color(color or {255, 0, 0, 255})
end

---Converts an RGB color value to HSL. Conversion formula
---adapted from http://en.wikipedia.org/wiki/HSL_color_space.
---Assumes r, g, and b are contained in the set [0, 255] and
---returns h, s, and l in the set [0, 1].
---@param rgba renderer.color
---@return table hsla
function ColorPicker.rgb_to_hsl(rgba)
  local r, g, b, a = rgba[1], rgba[2], rgba[3], rgba[4]
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return {h, s, l, a and a/255 or 1}
end

---Converts an HSL color value to RGB. Conversion formula
---adapted from http://en.wikipedia.org/wiki/HSL_color_space.
---Assumes h, s, and l are contained in the set [0, 1] and
---returns r, g, and b in the set [0, 255].
---@param h number The hue
---@param s number The saturation
---@param l number The lightness
---@param a number The alpha
---@return renderer.color rgba
function ColorPicker.hsl_to_rgb(h, s, l, a)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local function hue2rgb(p, q, t)
      if t < 0   then t = t + 1 end
      if t > 1   then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end

  return {r * 255, g * 255, b * 255, a * 255}
end

---Converts an RGB color value to HSV. Conversion formula
---adapted from http://en.wikipedia.org/wiki/HSV_color_space.
---Assumes r, g, and b are contained in the set [0, 255] and
---returns h, s, and v in the set [0, 1].
---@param rgba renderer.color
---@return table hsva The HSV representation
function ColorPicker.rgb_to_hsv(rgba)
  local r, g, b, a = rgba[1], rgba[2], rgba[3], rgba[4]
  r, g, b, a = r / 255, g / 255, b / 255, a / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return {h, s, v, a/255}
end

---Converts an HSV color value to RGB. Conversion formula
---adapted from http://en.wikipedia.org/wiki/HSV_color_space.
---Assumes h, s, and v are contained in the set [0, 1] and
---returns r, g, and b in the set [0, 255].
---@param h number The hue
---@param s number The saturation
---@param v number The brightness
---@param a number The alpha
---@return renderer.color rgba The RGB representation
function ColorPicker.hsv_to_rgb(h, s, v, a)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return {math.ceil(r * 255), math.ceil(g * 255), math.ceil(b * 255), math.ceil(a * 255)}
end

---Converts a css format color string into a renderer.color if possible,
---if conversion fails returns nil. Adapted from colorpreview plugin.
---@param color string
---@return renderer.color? color
function ColorPicker.color_from_string(color)
  local s, e, r, g, b, a, base, nibbles;

  s, e, r, g, b, a = color:find("#(%x%x)(%x%x)(%x%x)(%x?%x?)")

  if s then
    base = 16
  else
    s, e, r, g, b, a = color:find("#(%x)(%x)(%x)")

    if s then
      base = 16
      nibbles = true
    else
      s, e, r, g, b, a = color:find(
        "rgba?%((%d+)%D+(%d+)%D+(%d+)[%s,]-([%.%d]-)%s-%)"
      )
    end
  end

  if not s then return nil end

  r = tonumber(r or "", base)
  g = tonumber(g or "", base)
  b = tonumber(b or "", base)

  a = tonumber(a or "", base)
  if a ~= nil then
    if base ~= 16 then
      a = a * 0xff
    end
  else
    a = 0xff
  end

  if nibbles then
    r = r * 16
    g = g * 16
    b = b * 16
  end

  return {r, g, b, a}
end

---Gets a color between two given colors on the position
---defined by the given percent.
---@param from_color renderer.color
---@param to_color renderer.color
---@param percent number
---@return renderer.color color
function ColorPicker.color_in_between(from_color, to_color, percent)
  local color = {}
  for i=1, 4 do
    if from_color[i] == to_color[i] then
      color[i] = from_color[i]
    else
      color[i] = common.clamp(
        from_color[i] + math.floor((to_color[i] - from_color[i]) * percent),
        0,
        255
      )
    end
  end
  return color
end

function ColorPicker:get_name()
  return "Color Picker"
end

---Gets the currently selected color on the hue bar.
---@return renderer.color
function ColorPicker:get_hue_color()
  local w = self.selector.w
  local pos = self.hue_pos
  local pos_percent = pos / 100
  local range_size = w / 6
  local range
  if pos <= (HUE_COLOR_SEGMENT) then
    range = 1
  elseif pos <= (HUE_COLOR_SEGMENT) * 2 then
    range = 2
  elseif pos <= (HUE_COLOR_SEGMENT) * 3 then
    range = 3
  elseif pos <= (HUE_COLOR_SEGMENT) * 4 then
    range = 4
  elseif pos <= (HUE_COLOR_SEGMENT) * 5 then
    range = 5
  else
    range = 6
  end
  local range_position = (w * pos_percent) - ((range_size * range)-range_size)
  local range_percent = range_position / range_size
  return ColorPicker.color_in_between(
    HUE_COLOR_RANGES[range][1],
    HUE_COLOR_RANGES[range][2],
    range_percent
  )
end

---Gets the currently selected color on the saturation bar.
---@return renderer.color
function ColorPicker:get_saturation_color()
  local w = self.selector.w
  local pos = self.saturation_pos
  local pos_percent = pos / 100
  local range_size = w
  local range, color1, color2 = 1, COLOR_WHITE, self.hue_color
  local range_position = (w * pos_percent) - ((range_size * range)-range_size)
  local range_percent = range_position / range_size
  return ColorPicker.color_in_between(color1, color2, range_percent)
end

---Gets the currently selected color on the brightness bar.
---@return renderer.color
function ColorPicker:get_brightness_color()
  local w = self.selector.w
  local pos = self.brightness_pos
  local pos_percent = pos / 100
  local range_size = w
  local range, color1, color2 = 1, COLOR_BLACK, self.saturation_color
  local range_position = (w * pos_percent) - ((range_size * range)-range_size)
  local range_percent = range_position / range_size
  return ColorPicker.color_in_between(color1, color2, range_percent)
end

---Gets the currently selected rgba color.
---@return renderer.color
function ColorPicker:get_color()
  return ColorPicker.hsv_to_rgb(
    self.hue_pos / 100,
    self.saturation_pos / 100,
    self.brightness_pos / 100,
    self.alpha / 255
  )
end

---Set current color from rgba source which can also
---be a css string representation.
---@param color renderer.color | string
function ColorPicker:set_color(color, skip_html, skip_rgba)
  -- we set the color on a coroutine in case it is been set before
  -- the control is properly initialized like the constructor.
  core.add_thread(function()
    if type(color) == "string" then
      color = ColorPicker.color_from_string(color)
    end

    if not color then return end

    local hsva = ColorPicker.rgb_to_hsv(color)

    self.hue_pos = hsva[1] * 100
    self.saturation_pos = hsva[2] * 100
    self.brightness_pos = hsva[3] * 100

    self.hue_color = self:get_hue_color()
    self.saturation_color = self:get_saturation_color()
    self.brightness_color = self:get_brightness_color()
    self.alpha = color[4]

    if not skip_html then
      self.html_updating = true
      self.html_notation:set_text(string.format(
        "#%02X%02X%02X%02X",
        color[1], color[2], color[3], color[4]
      ))
      self.html_updating = false
    end

    if not skip_rgba then
      self.rgba_updating = true
      self.rgba_notation:set_text(string.format(
        "rgba(%d,%d,%d,%.2f)",
        color[1], color[2], color[3], color[4] / 255
      ))
      self.rgba_updating = false
    end

    self:on_change(color)
  end)
end

---Set the transparency level, the lower the given alpha the more transparent.
---@param alpha number A value from 0 to 255
function ColorPicker:set_alpha(alpha)
  self.alpha = common.clamp(alpha, 0, 255)
end

---Draw a hue color bar at given location and size.
---@param x number
---@param y number
---@param w number
---@param h number
function ColorPicker:draw_hue(x, y, w, h)
  local sx = x
  local step = 1
  local cwidth = 1
  local cheight = h or 10

  if w < 255*6 then
    step = 255 / (w / 6)
  else
    cwidth = (w / 6) / 255
  end

  -- red -> yellow
  for g=0, 255, step do
    renderer.draw_rect(x, y, cwidth, cheight, {255, g, 0, 255})
    x = x + cwidth
  end

  -- yellow -> green
  for r=255, 0, -step do
    renderer.draw_rect(x, y, cwidth, cheight, {r, 255, 0, 255})
    x = x + cwidth
  end

  -- green -> cyan
  for b=0, 255, step do
    renderer.draw_rect(x, y, cwidth, cheight, {0, 255, b, 255})
    x = x + cwidth
  end

  -- cyan -> blue
  for g=255, 0, -step do
    renderer.draw_rect(x, y, cwidth, cheight, {0, g, 255, 255})
    x = x + cwidth
  end

  -- blue -> purple
  for r=0, 255, step do
    renderer.draw_rect(x, y, cwidth, cheight, {r, 0, 255, 255})
    x = x + cwidth
  end

  -- purple -> red
  for b=255, 0, -step do
    renderer.draw_rect(x, y, cwidth, cheight, {255, 0, b, 255})
    x = x + cwidth
  end

  sx = sx + (w * (self.hue_pos / 100))
  self:draw_selector(sx, y, cheight, self.hue_color)
end

---Draw a saturation color bar at given location and size.
---@param x number
---@param y number
---@param w number
---@param h number
function ColorPicker:draw_saturation(x, y, w, h)
  local sx = x
  local step = 1
  local cwidth = 1
  local cheight = h or 10

  if w < 255 then
    step = 255 / w
  else
    cwidth = w / 255
  end

  -- white to base
  for i=0, 255, step do
    local color = ColorPicker.color_in_between(COLOR_WHITE, self.hue_color, i / 255)
    renderer.draw_rect(x, y, cwidth, cheight, color)
    x = x + cwidth
  end

  sx = sx + (w * (self.saturation_pos / 100))
  self:draw_selector(sx, y, cheight, self.saturation_color)
end

---Draw a brightness color bar at given location and size.
---@param x number
---@param y number
---@param w number
---@param h number
function ColorPicker:draw_brightness(x, y, w, h)
  local sx = x
  local step = 1
  local cwidth = 1
  local cheight = h or 10

  if w < 255 then
    step = 255 / w
  else
    cwidth = w / 255
  end

  -- black to base
  for i=0, 255, step do
    local color = ColorPicker.color_in_between(COLOR_BLACK, self.saturation_color, i / 255)
    renderer.draw_rect(x, y, cwidth, cheight, color)
    x = x + cwidth
  end

  sx = sx + (w * (self.brightness_pos / 100))
  self:draw_selector(sx, y, cheight, self.brightness_color)
end

---@param self widget.colorpicker
local function update_control_values(self)
  local color = self:get_color()
  self.alpha = color[4]
  self.html_notation:set_text(string.format(
    "#%02X%02X%02X%02X",
    color[1], color[2], color[3], color[4]
  ))
  self.rgba_notation:set_text(string.format(
    "rgba(%d,%d,%d,%.2f)",
    color[1], color[2], color[3], color[4] / 255
  ))
  self:on_change(color)
end

function ColorPicker:on_mouse_pressed(button, x, y, clicks)
  if not ColorPicker.super.on_mouse_pressed(self, button, x, y, clicks) then
    return false
  end

  if
    x >= self.selector.x and x <= self.selector.x + self.selector.w
    and
    y >= self.selector.y and y <= self.selector.y + self.selector.h
  then
    local sx, sw = self.selector.x, self.selector.w
    self.hue_pos = common.clamp(x, sx, sx + sw)
    self.hue_pos = ((self.hue_pos - self.selector.x) / self.selector.w) * 100
    self.hue_color = self:get_hue_color()
    self.saturation_color = self:get_saturation_color()
    self.hue_mouse_down = true
  elseif
    x >= self.selector.x and x <= self.selector.x + self.selector.w
    and
    y >= self.selector.y + style.padding.y + self.selector.h
    and
    y <= self.selector.y + style.padding.y + (self.selector.h * 2)
  then
    local sx, sw = self.selector.x, self.selector.w
    self.saturation_pos = common.clamp(x, sx, sx + sw)
    self.saturation_pos = ((self.saturation_pos - self.selector.x) / self.selector.w) * 100
    self.saturation_color = self:get_saturation_color()
    self.brightness_color = self:get_brightness_color()
    self.saturation_mouse_down = true
  elseif
    x >= self.selector.x and x <= self.selector.x + self.selector.w
    and
    y >= self.selector.y + style.padding.y * 2 + self.selector.h * 2
    and
    y <= self.selector.y + style.padding.y * 2 + (self.selector.h * 4)
  then
    local sx, sw = self.selector.x, self.selector.w
    self.brightness_pos = common.clamp(x, sx, sx + sw)
    self.brightness_pos = ((self.brightness_pos - self.selector.x) / self.selector.w) * 100
    self.brightness_color = self:get_brightness_color()
    self.brightness_mouse_down = true
  end
  if self.hue_mouse_down or self.saturation_mouse_down or self.brightness_mouse_down then
    update_control_values(self)
  end
  return true
end

function ColorPicker:on_mouse_released(button, x, y)
  if not ColorPicker.super.on_mouse_released(self, button, x, y) then
    return false
  end
  self.hue_mouse_down = false
  self.saturation_mouse_down = false
  self.brightness_mouse_down = false
  return true
end

function ColorPicker:on_mouse_moved(x, y, dx, dy)
  if not ColorPicker.super.on_mouse_moved(self, x, y, dx, dy) then
    return false
  end
  if self.hue_mouse_down then
    local sx, sw = self.selector.x, self.selector.w
    self.hue_pos = common.clamp(x, sx, sx + sw)
    self.hue_pos = ((self.hue_pos - self.selector.x) / self.selector.w) * 100
    self.hue_color = self:get_hue_color()
    self.saturation_color = self:get_saturation_color()
    self.brightness_color = self:get_brightness_color()
  elseif self.saturation_mouse_down then
    local sx, sw = self.selector.x, self.selector.w
    self.saturation_pos = common.clamp(x, sx, sx + sw)
    self.saturation_pos = ((self.saturation_pos - self.selector.x) / self.selector.w) * 100
    self.saturation_color = self:get_saturation_color()
    self.brightness_color = self:get_brightness_color()
  elseif self.brightness_mouse_down then
    local sx, sw = self.selector.x, self.selector.w
    self.brightness_pos = common.clamp(x, sx, sx + sw)
    self.brightness_pos = ((self.brightness_pos - self.selector.x) / self.selector.w) * 100
    self.brightness_color = self:get_brightness_color()
  end
  if self.hue_mouse_down or self.saturation_mouse_down or self.brightness_mouse_down then
    update_control_values(self)
  end
  return true
end

function ColorPicker:update()
  if not ColorPicker.super.update(self) then return false end
  local x, y = 0, style.padding.y * 3 + self.selector.h * 4
  self.html_notation:set_position(x, y)
  self.rgba_notation:set_position(self.html_notation:get_right() + style.padding.x, y)
  if self:get_width() < self.rgba_notation:get_right() then
    self:set_size(self.rgba_notation:get_right() + style.padding.x)
  end
  if self:get_height() < self.rgba_notation:get_bottom() then
    self:set_size(nil, self.rgba_notation:get_bottom() + style.padding.y)
  end
  return true
end

function ColorPicker:draw_selector(x, y, h, color)
  local border = 2 * SCALE
  x = x - border - ((10 * SCALE) / border)
  y = y - border
  renderer.draw_rect(x, y, 14 * SCALE, h + (border * 2), COLOR_WHITE)
  renderer.draw_rect(x+border, y + border, 10 * SCALE, h, color)
end

function ColorPicker:draw()
  if not ColorPicker.super.draw(self) then return false end

  local x, y, w = self.position.x, self.position.y, self.size.x

  self.selector.x = x
  self.selector.y = style.padding.y + y
  self.selector.w = w - style.padding.x - 100
  self.selector.h = 10 * SCALE

  self:draw_hue(
    self.selector.x,
    self.selector.y,
    self.selector.w,
    self.selector.h
  )

  self:draw_saturation(
    self.selector.x,
    self.selector.y + style.padding.y + self.selector.h,
    self.selector.w,
    self.selector.h
  )

  self:draw_brightness(
    self.selector.x,
    self.selector.y + style.padding.y * 2 + self.selector.h * 2,
    self.selector.w,
    self.selector.h
  )

  local c = self:get_color()

  renderer.draw_rect(
    self.selector.x + style.padding.x + self.selector.w,
    self.selector.y,
    100,
    (self.selector.y + style.padding.y * 2 + self.selector.h * 3)
      - self.selector.y,
    c
  )

  return true
end


return ColorPicker
