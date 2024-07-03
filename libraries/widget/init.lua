--
-- Base widget implementation for lite.
-- @copyright Jefferson Gonzalez
-- @license MIT
--

local core = require "core"
local config = require "core.config"
local style = require "core.style"
local keymap = require "core.keymap"
local View = require "core.view"
local RootView = require "core.rootview"
local ScrollBar = require "libraries.widget.scrollbar"

---Represents the border of a widget.
---@class widget.border
---@field public width number
---@field public color renderer.color | nil

---Represents the position of a widget.
---@class widget.position
---@field public x number Real X
---@field public y number Real y
---@field public rx number Relative X
---@field public ry number Relative Y
---@field public dx number Dragging initial x position
---@field public dy number Dragging initial y position

---@class widget.animation.options
---Prevents duplicated animations from getting added.
---@field name? string
---Speed of the animation, defaults to 0.5
---@field rate? number
---Called each time the value of a property changes.
---@field on_step? fun(target:table, property:string, value:number)
---Called when the animation finishes.
---@field on_complete? fun(widget:widget)

---@class widget.animation
---@field target table
---@field properties table<string,number>
---@field options? widget.animation.options

---Represents a reference to a font stored elsewhere.
---@class widget.fontreference
---@field public container table<string, renderer.font>
---@field public name string

---@alias widget.font widget.fontreference | renderer.font | string

---@alias widget.clicktype
---| "left"
---| "right"

---@alias widget.styledtext table<integer, renderer.font|widget.fontreference|renderer.color|integer|string>

---A base widget
---@class widget : core.view
---@field public super widget
---@field public parent widget | nil
---@field public name string
---@field public position widget.position
---Modifying this property directly is not advised, use set_size() instead.
---@field public size widget.position
---@field public childs table<integer,widget>
---@field public child_active widget | nil
---@field public zindex integer
---@field public border widget.border
---@field public clickable boolean
---@field public draggable boolean
---@field public scrollable boolean
---@field public font widget.font
---@field public foreground_color renderer.color
---@field public background_color renderer.color
---@field public render_background boolean
---@field public type_name string
---@field protected visible boolean
---@field protected has_focus boolean
---@field protected dragged boolean
---@field protected tooltip string
---@field protected label string | widget.styledtext
---@field protected input_text boolean
---@field protected textview widget
---@field protected next_zindex integer
---@field protected mouse widget.position
---@field protected prev_size widget.position
---@field protected mouse_is_pressed boolean
---@field protected mouse_is_hovering boolean
---@field protected mouse_pressed_outside boolean
---@field protected is_scrolling boolean
---@field protected animations widget.animation[]
local Widget = View:extend()

---Indicates on a widget.styledtext that a new line follows.
---@type integer
Widget.NEWLINE = 1

---Keep track of last hovered widget to properly trigger on_mouse_leave
---@type widget | nil
local last_hovered_child = nil

---A list of floating widgets that need to receive events.
---@type table<integer, widget>
local floating_widgets = {}

---When no parent is given to the widget constructor it will automatically
---overwrite RootView methods to intercept system events.
---@param parent? widget
---@param floating? boolean | nil
function Widget:new(parent, floating)
  Widget.super.new(self)

  self.v_scrollbar = ScrollBar(self, {direction = "v", alignment = "e"})
  self.h_scrollbar = ScrollBar(self, {direction = "h", alignment = "e"})

  self.type_name = "widget"
  self.parent = parent
  self.name = "---" -- defaults to the application name
  if type(floating) == "boolean" then
    self.defer_draw =  floating
  else
    self.defer_draw = true
  end
  self.childs = {}
  self.child_active = nil
  self.zindex = nil
  self.next_zindex = 1
  self.border = {
    width = 1,
    color = nil
  }
  self.foreground_color = nil
  self.background_color = nil
  self.render_background = true
  self.visible = parent and true or false
  self.has_focus = false
  self.clickable = true
  self.draggable = false
  self.dragged = false
  self.font = "font"
  self.tooltip = ""
  self.label = ""
  self.input_text = false
  self.textview = nil
  self.mouse = {x = 0, y = 0}
  self.prev_size = {x = 0, y = 0}
  self.is_scrolling = false

  self.mouse_is_pressed = false
  self.mouse_is_hovering = false

  -- used to allow proper node resizing
  self.mouse_pressed_outside = false

  self.animations = {}

  if parent then
    parent:add_child(self)
  elseif self.defer_draw then
    table.insert(floating_widgets, self)
    Widget.override_rootview()
  end

  self:set_position(0, 0)
end

---Useful for debugging.
function Widget:__tostring()
  return self.type_name
end

---Add a child widget, automatically assign a zindex if non set and sorts
---them in reverse order for better events matching.
---@param child widget
function Widget:add_child(child)
  if not child.zindex then
    child.zindex = self.next_zindex
    self.next_zindex = self.next_zindex + 1
  end

  table.insert(self.childs, child)
  table.sort(self.childs, function(t1, t2) return t1.zindex > t2.zindex end)
end

---Remove a child widget.
---@param child widget
function Widget:remove_child(child)
  for position, element in ipairs(self.childs) do
    if child == element then
      child:destroy_childs()
      table.remove(self.childs, position)
      break
    end
  end
end

---Show the widget.
function Widget:show()
  if not self.parent then
    if self.size.x <= 0 or self.size.y <= 0 then
      self.size.x = self.prev_size.x
      self.size.y = self.prev_size.y
    end
    self.prev_size.x = 0
    self.prev_size.y = 0
  end
  self.visible = true
  -- re-triggers update to make sure everything was properly calculated
  -- and redraw the interface once, maybe something else can be changed
  -- to not require this action, but for now lets do this.
  core.add_thread(function()
    self:update()
    core.redraw = true
  end)
end

---Perform an animated show.
---@param lock_x? boolean Do not resize width while animating
---@param lock_y? boolean Do not resize height while animating
---@param options? widget.animation.options
function Widget:show_animated(lock_x, lock_y, options)
  if not self.parent then
    if self.size.x <= 0 or self.size.y <= 0 then
      self.size.x = self.prev_size.x
      self.size.y = self.prev_size.y
    end
    self.prev_size.x = 0
    self.prev_size.y = 0
  end

  local target_x, target_y = math.floor(self.size.x), math.floor(self.size.y)
  self.size.x = lock_x and target_x or 0
  self.size.y = lock_y and target_y or 0
  local properties = {}
  if not lock_x then properties["x"] = target_x end
  if not lock_y then properties["y"] = target_y end
  options = options or {}
  self:animate(self.size, properties, {
    name = options.name or "show_animated",
    rate = options.rate,
    on_step = options.on_step,
    on_complete = options.on_complete
  })

  self.visible = true
end

---Hide the widget.
function Widget:hide()
  self.visible = false
  -- we need to force size to zero on parent widget to properly hide it
  -- when used as a lite node, otherwise the reserved space of the node
  -- will stay visible and dragging will reveal empty space.
  if not self.parent then
    if self.size.x > 0 or self.size.y > 0 then
      -- we only do this once to prevent issues of consecutive hide calls
      if self.prev_size.x == 0 and self.prev_size.y == 0 then
        self.prev_size.x = self.size.x
        self.prev_size.y = self.size.y
      end
      self.size.x = 0
      self.size.y = 0
    end
  end
end

---Perform an animated hide.
---@param lock_x? boolean Do not resize width while animating
---@param lock_y? boolean Do not resize height while animating
---@param options? widget.animation.options
function Widget:hide_animated(lock_x, lock_y, options)
  local x, y = self.size.x, self.size.y
  local target_x = lock_x and self.size.x or 0
  local target_y = lock_y and self.size.y or 0
  local properties = {}
  if not lock_x then properties["x"] = target_x end
  if not lock_y then properties["y"] = target_y end
  options = options or {}
  self:animate(self.size, properties, {
    name = options.name or "hide_animated",
    rate = options.rate,
    on_step = options.on_step,
    on_complete = function()
      self.size.x, self.size.y = x, y
      self:hide()
      if options.on_complete then
        options.on_complete(self)
      end
    end
  })
end

---When set to false the background rendering is disabled.
---@param enable? boolean | nil
function Widget:toggle_background(enable)
  if type(enable) == "boolean" then
    self.render_background = enable
  else
    self.render_background = not self.render_background
  end
end

---Toggle visibility of widget.
---@param animated? boolean
---@param lock_x? boolean
---@param lock_y? boolean
---@param options? widget.animation.options
function Widget:toggle_visible(animated, lock_x, lock_y, options)
  if not self.visible then
    if not animated then
      self:show()
    else
      self:show_animated(lock_x, lock_y, options)
    end
  else
    if not animated then
      self:hide()
    else
      self:hide_animated(lock_x, lock_y, options)
    end
  end
end

---Check if the widget is visible also recursing to the parent visibility.
---@return boolean
function Widget:is_visible()
  if
    not self.visible or (self.parent and not self.parent:is_visible())
  then
    return false
  end
  return true
end

---Taken from the logview and modified it a tiny bit.
---TODO: something similar should be on lite-xl core.
---@param font widget.font
---@param text string
---@param x integer
---@param y integer
---@param color renderer.color
---@param only_calc boolean
---@return integer resx
---@return integer resy
---@return integer width
---@return integer height
function Widget:draw_text_multiline(font, text, x, y, color, only_calc)
  font = self:get_font(font)
  local th = font:get_height()
  local resx, resy = x, y
  local width, height = 0, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    resy = y
    if only_calc then
      resx = x + font:get_width(line)
    else
      resx = renderer.draw_text(font, line, x, y, color)
    end
    y = y + th
    width = math.max(width, resx - x)
    height = height + th
  end
  return resx, resy, width, height
end

---Render or calculate the size of the specified range of elements
---in a styled text elemet.
---@param text widget.styledtext
---@param start_idx integer
---@param end_idx integer
---@param x integer
---@param y integer
---@param only_calc boolean
---@return integer width
---@return integer height
function Widget:draw_styled_text(text, x, y, only_calc, start_idx, end_idx)
  local font = self:get_font()
  local color = self.foreground_color or style.text
  local width = 0
  local height = font:get_height()
  local new_line = false
  local nx = x

  start_idx = start_idx or 1
  end_idx = end_idx or #text

  for pos=start_idx, end_idx, 1 do
    local element = text[pos]
    local ele_type = type(element)
    if
      ele_type == "userdata"
      or
      (element.container or type(element[1]) == "userdata")
    then
      if ele_type == "table" and element.container then
        font = element.container[element.name]
      else
        font = element
      end
    elseif ele_type == "table" then
      color = element
    elseif element == Widget.NEWLINE then
      y = y + font:get_height()
      nx = x
      new_line = true
    elseif ele_type == "string" then
      local rx, ry, w, h = self:draw_text_multiline(
        font, element, nx, y, color, only_calc
      )
      y = ry
      nx = rx
      if new_line then
        height = height + h
        width = math.max(width, w)
        new_line = false
      else
        height = math.max(height, h)
        width = width + w
      end
    end
  end

  return width, height
end

---Draw the widget configured border or custom one.
---@param x? number
---@param y? number
---@param w? number
---@param h? number
function Widget:draw_border(x, y, w, h)
  if self.border.width <= 0 then return end

  x = x or self.position.x
  y = y or self.position.y
  w = w or self.size.x
  h = h or self.size.y

  x = x - self.border.width
  y = y - self.border.width
  w = w + (self.border.width * 2)
  h = h + (self.border.width * 2)

  -- Draw lines instead of full rectangle to be able to draw on top

  --top
  renderer.draw_rect(
    x, y, w + x % 1 - self.border.width, self.border.width,
    self.border.color or style.text
  )
  --bottom
  renderer.draw_rect(
    x, y+h - self.border.width, w + x % 1 - self.border.width, self.border.width,
    self.border.color or style.text
  )
  --right
  renderer.draw_rect(
    x+w - self.border.width, y, self.border.width, h,
    self.border.color or style.text
  )
  --left
  renderer.draw_rect(
    x, y, self.border.width, h,
    self.border.color or style.text
  )
end

---Called by lite node system to properly resize the widget.
---@param axis string | "'x'" | "'y'"
---@param value number
function Widget:set_target_size(axis, value)
  if not self.visible then
    return false
  end
  if axis == "x" then
    self:set_size(value)
  else
    self:set_size(nil, value)
  end
  return true
end

---@param width? integer
---@param height? integer
function Widget:set_size(width, height)
  -- take into consideration the border as part of size
  if width then
    if width > (self.border.width * 2) then
      width = width - (self.border.width * 2)
    else
      width = 0
    end
  end
  if height then
    if height > (self.border.width * 2) then
      height = height - (self.border.width * 2)
    else
      height = 0
    end
  end

  if not self.parent and not self.visible then
    if width then self.prev_size.x = width end
    if height then self.prev_size.y = height end
  else
    if width then self.size.x = width end
    if height then self.size.y = height end
  end
end

---Set the widget border size and appropriately re-set the widget size.
---@param width integer
function Widget:set_border_width(width)
  local wwidth, wheight = 0, 0;
  if self.border.width > 0 then
    local prev_width = self.border.width * 2
    if not self.parent and not self.visible then
      wwidth = self.prev_size.x + prev_width
      wheight = self.prev_size.y + prev_width
    else
      wwidth = self.size.x + prev_width
      wheight = self.size.y + prev_width
    end
  end
  self.border.width = width
  self:set_size(wwidth, wheight)
end

---Called on the update function to be able to scroll the child widgets.
function Widget:update_position()
  if self.parent then
    self.position.x = self.position.rx + self.border.width
    self.position.y = self.position.ry + self.border.width

    -- add offset to properly scroll
    local ox, oy = self.parent:get_content_offset()
    self.position.x = ox + self.position.x
    self.position.y = oy + self.position.y
  end

  for _, child in pairs(self.childs) do
    child:update_position()
  end
end

---Set the position of the widget and updates the child absolute coordinates
---@param x? integer
---@param y? integer
function Widget:set_position(x, y)
  if x then self.position.x = x + self.border.width end
  if y then self.position.y = y + self.border.width end

  if self.parent then
    -- add offset to properly scroll
    local ox, oy = self.parent:get_content_offset()

    if x then
      self.position.rx = x
      self.position.x = ox + self.position.x
    end

    if y then
      self.position.ry = y
      self.position.y = oy + self.position.y
    end
  end

  if x or y then
    for _, child in pairs(self.childs) do
      child:set_position(child.position.rx, child.position.ry)
    end
  end
end

---Get the real renderer.font associated with a widget.font.
---@param font? widget.font
---@return renderer.font
function Widget:get_font(font)
  if not font then font = self.font end
  local font_type = type(font)
  if font_type == "userdata" then
    return font
  elseif font_type == "string" then
    return style[font]
  elseif font and font.container then
    return font.container[font.name]
  end
  if not font then
    return style.font
  end
  return font
end

---Get the relative position in relation to parent
---@return widget.position
function Widget:get_position()
  local position = { x = self.position.x, y = self.position.y }
  if self.parent then
    position.x = self.position.rx
    position.y = self.position.ry
  end
  return position
end

---Get width including borders.
---@return number
function Widget:get_width()
  return self.size.x + (self.border.width * 2)
end

---Get height including borders.
---@return number
function Widget:get_height()
  return self.size.y + (self.border.width * 2)
end

---Get the right x coordinate relative to parent
---@return number
function Widget:get_right()
  return self:get_position().x + self:get_width()
end

---Get the bottom y coordinate relative to parent
---@return number
function Widget:get_bottom()
  return self:get_position().y + self:get_height()
end

---Overall height of the widget accounting all visible child widgets.
---@return number
function Widget:get_real_height()
  local size = 0
  for _, child in pairs(self.childs) do
    if child.visible then
      size = math.max(size, child:get_bottom())
    end
  end
  return size
end

---Overall width of the widget accounting all visible child widgets.
---@return number
function Widget:get_real_width()
  local size = 0
  for _, child in pairs(self.childs) do
    if child.visible then
      size = math.max(size, child:get_right())
    end
  end
  return size
end

---Check if the given mouse coordinate is hovering the widget
---@param x number
---@param y number
---@return boolean
function Widget:mouse_on_top(x, y)
  return
    self.visible
    and
    x >= self.position.x - self.border.width
    and
    x <= self.position.x - self.border.width + self:get_width()
    and
    y >= self.position.y - self.border.width
    and
    y <= self.position.y - self.border.width + self:get_height()
end

---Mark a widget as having focus.
---TODO: Implement set focus system by pressing a key like tab?
function Widget:set_focus(has_focus)
  self.set_focus = has_focus
end

---Text displayed when the widget is hovered.
---@param tooltip string
function Widget:set_tooltip(tooltip)
  self.tooltip = tooltip
end

---A text label for the widget, not all widgets support this.
---@param text string | widget.styledtext
function Widget:set_label(text)
  self.label = text
end

---Used internally when dragging is activated.
---@param x number
---@param y number
function Widget:drag(x, y)
  self:set_position(x - self.position.dx, y - self.position.dy)
end

---Center the widget horizontally and vertically to the screen or parent widget.
function Widget:centered()
  local w, h = system.get_window_size();
  if self.parent then
    w = self.parent:get_width()
    h = self.parent:get_height()
  end
  self:set_position(
    (w / 2) - (self:get_width() / 2),
    (h / 2) - (self:get_height() / 2)
  )
end

---Replaces current active child with a new one and calls the
---activate/deactivate events of the child. This is especially
---used to send text input events to widgets with input_text support.
---@param child? widget If nil deactivates current child
function Widget:swap_active_child(child)
  if self.parent then
    self.parent:swap_active_child(child)
    return
  end

  if child and child == self.child_active then return end

  local active_child = self.child_active

  if self.child_active then
    self.child_active:deactivate()
  end

  self.child_active = child

  if child then
    if not self.prev_view then
      self.prev_view = core.active_view
    end
    core.set_active_view(child.input_text and child.textview or child)
    self.child_active:activate()
  elseif self.prev_view then
    -- return focus to previous view
    if self.prev_view ~= active_child then
      core.set_active_view(self.prev_view)
    else
      core.set_active_view(self)
    end
    self.prev_view = nil
  end
end

---Calculates the y scrollable size taking into account the bottom most
---widget or the size of the widget it self if greater.
---@return number
function Widget:get_scrollable_size()
  return math.max(self.size.y, self:get_real_height())
end

---Calculates the x scrollable size taking into account the right most
---widget or the size of the widget it self if greater.
---@return number
function Widget:get_h_scrollable_size()
  return math.max(self.size.x, self:get_real_width())
end

---The name that is displayed on lite-xl tabs.
function Widget:get_name()
  return self.name
end

--
-- Events
--

---Send file drop event to hovered child.
---@param filename string
---@param x number
---@param y number
---@return boolean processed
function Widget:on_file_dropped(filename, x, y)
  if not self.visible then return false end

  for _, child in pairs(self.childs) do
    if child:mouse_on_top(x, y) then
      return child:on_file_dropped(filename, x, y)
    end
  end

  return false
end

---Redirects any text input to active child with the input_text flag.
---@param text string
---@return boolean processed
function Widget:on_text_input(text)
  if not self.visible then return false end

  Widget.super.on_text_input(self, text)

  if self.child_active then
    self.child_active:on_text_input(text)
    return true
  end

  return false
end

---Send mouse pressed events to hovered child or starts dragging if enabled.
---@param button widget.clicktype
---@param x number
---@param y number
---@param clicks integer
---@return boolean processed
function Widget:on_mouse_pressed(button, x, y, clicks)
  if not self.visible then return false end

  if Widget.super.on_mouse_pressed(self, button, x, y, clicks) then
    local parent = self.parent
    while parent do
      -- propagate to parents so if mouse is not on top still
      -- reach the childrens when the mouse is released
      parent.is_scrolling = true
      parent = parent.parent
    end
    self.is_scrolling = true
    return true
  end

  for _, child in pairs(self.childs) do
    if child:mouse_on_top(x, y) and child.clickable then
      child:on_mouse_pressed(button, x, y, clicks)
      return true
    end
  end

  if self:mouse_on_top(x, y) then
    self.mouse_is_pressed = true

    if self.parent then
      -- propagate to parents so if mouse is not on top still
      -- reach the childrens when the mouse is released
      self.parent.mouse_is_pressed = true
    end

    if self.draggable and not self.child_active then
      self.position.dx = x - self.position.x
      self.position.dy = y - self.position.y
      system.set_cursor("hand")
    end
  else
    self:swap_active_child()
    return false
  end

  return true
end

---Send mouse released events to hovered child, ends dragging if enabled and
---emits on click events if applicable.
---@param button widget.clicktype
---@param x number
---@param y number
---@return boolean processed
function Widget:on_mouse_released(button, x, y)
  if not self.visible then return false end

  Widget.super.on_mouse_released(self, button, x, y)

  if self.is_scrolling then
    self.is_scrolling = false
    local parent = self.parent
    while parent do
      parent.is_scrolling = false
      parent = parent.parent
    end
    for _, child in pairs(self.childs) do
      if child.is_scrolling then
        child:on_mouse_released(button, x, y)
      end
    end
    return true
  end

  self:swap_active_child()

  if self.child_active then
    self.child_active:on_mouse_released(button, x, y)
  end

  if not self.dragged then
    for _, child in pairs(self.childs) do
      local mouse_on_top = child:mouse_on_top(x, y)
      if
        mouse_on_top
        or
        child.mouse_is_pressed
      then
        child:on_mouse_released(button, x, y)
        if child.input_text then
          self:swap_active_child(child)
        end
        if mouse_on_top and child.mouse_is_pressed then
          child:on_click(button, x, y)
        end
        return true
      end
    end
  end

  if
    not self.dragged
    and
    not self.mouse_is_pressed
  then
    return false
  end

  if self.mouse_is_pressed then
    if self:mouse_on_top(x, y) then
      self:on_click(button, x, y)
    end
    self.mouse_is_pressed = false
    if self.parent then
      self.parent.mouse_is_pressed = false
    end
    if self.draggable then
      system.set_cursor("arrow")
    end
  end

  self.dragged = false

  return true
end

---Event emitted when the value of the widget changes.
---If applicable, child widgets should call this method
---when its value changes.
---@param value any
function Widget:on_change(value) end

---Click event emitted on a succesful on_mouse_pressed
---and on_mouse_released events combo.
---@param button widget.clicktype
---@param x number
---@param y number
function Widget:on_click(button, x, y) end

---Emitted to input_text widgets when clicked.
function Widget:activate() end

---Emitted to input_text widgets on lost focus.
function Widget:deactivate() end

---Besides the on_mouse_moved this event emits on_mouse_enter
---and on_mouse_leave for easy hover effects. Also, if the
---widget is scrollable and pressed this will drag it unless
---there is an active input_text child active.
---@param x number
---@param y number
---@param dx number
---@param dy number
function Widget:on_mouse_moved(x, y, dx, dy)
  if not self.visible then return false end

  Widget.super.on_mouse_moved(self, x, y, dx, dy)

  if self.is_scrolling then
    if not self:scrollbar_dragging() then
      for _, child in pairs(self.childs) do
        if child.is_scrolling then
          child:on_mouse_moved(x, y, dx, dy)
          break
        end
      end
    end
    return true
  end

  -- store latest mouse coordinates for usage on the on_mouse_wheel event.
  self.mouse.x = x
  self.mouse.y = y

  if self.child_active then
    self.child_active:on_mouse_moved(x, y, dx, dy)
  end

  if not self.dragged then
    local hovered = nil
    for _, child in pairs(self.childs) do
      if
        not hovered
        and
        (child:mouse_on_top(x, y) or child.mouse_is_pressed)
      then
        hovered = child
      elseif child.mouse_is_hovering then
        child.mouse_is_hovering = false
        if #child.tooltip > 0 then
          core.status_view:remove_tooltip()
        end
        child:on_mouse_leave(x, y, dx, dy)
        system.set_cursor("arrow")
      end
    end

    if hovered then
      hovered:on_mouse_moved(x, y, dx, dy)
      if last_hovered_child and not last_hovered_child:mouse_on_top(x, y) then
        last_hovered_child:on_mouse_leave(x, y, dx, dy)
        last_hovered_child.mouse_is_hovering = false
        last_hovered_child = nil
      end
      return true;
    end
  end

  if
    not self:mouse_on_top(x, y)
    and
    not self.mouse_is_pressed
    and
    not self.mouse_is_hovering
  then
    return false
  end

  local is_over = true

  if self:mouse_on_top(x, y) then
    if not self.mouse_is_hovering  then
      system.set_cursor("arrow")
      self.mouse_is_hovering = true
      if #self.tooltip > 0 then
        core.status_view:show_tooltip(self.tooltip)
      end
      self:on_mouse_enter(x, y, dx, dy)
      last_hovered_child = self
    end
  else
    self:on_mouse_leave(x, y, dx, dy)
    self.mouse_is_hovering = false
    is_over = false
  end

  if not self.child_active and self.mouse_is_pressed and self.draggable then
    system.set_cursor("hand")
    self:drag(x, y)
    self.dragged = true
    return true
  end

  return is_over
end

---Emitted once when the mouse hovers the widget.
function Widget:on_mouse_enter(x, y, dx, dy)
  for _, child in pairs(self.childs) do
    if child:mouse_on_top(x, y) then
      child:on_mouse_enter(x, y, dx, dy)
      break
    end
  end
end

---Emitted once when the mouse leaves the widget.
function Widget:on_mouse_leave(x, y, dx, dy)
  for _, child in pairs(self.childs) do
    if child.mouse_is_hovering then
      child:on_mouse_leave(x, y, dx, dy)
    end
  end
end

function Widget:on_mouse_wheel(y, x)
  if
    not self.visible
    or
    not self:mouse_on_top(self.mouse.x, self.mouse.y)
  then
    return false
  end

  for _, child in pairs(self.childs) do
    if child:mouse_on_top(self.mouse.x, self.mouse.y) then
      if child:on_mouse_wheel(y, x) then
        return true
      end
    end
  end

  if self.scrollable then
    if keymap.modkeys["shift"] then
      x = y
      y = 0
    end
    if y and y ~= 0 then
      self.scroll.to.y = self.scroll.to.y + y * -config.mouse_wheel_scroll
    end
    if x and x ~= 0 then
      self.scroll.to.x = self.scroll.to.x + x * -config.mouse_wheel_scroll
    end
    return true
  end

  return false
end

---Can be overriden by widgets to listen for scale change events to apply
---any neccesary changes in sizes, padding, etc...
---@param new_scale number
---@param prev_scale number
function Widget:on_scale_change(new_scale, prev_scale)
  local font_type = type(self.font)
  if
    font_type == "userdata"
    or
    (font_type == "table" and not self.font.container)
  then
    self.font:set_size(
      self.font:get_size() * (new_scale / prev_scale)
    )
  end
end

---Registers a new animation to be ran on the update cycle.
---@param target? table If nil assumes properties belong to widget it self.
---@param properties table<string,number>
---@param options? widget.animation.options
function Widget:animate(target, properties, options)
  if not target then target = self end

  -- if name is set then prevent adding if another one with the same
  -- animation name is already running
  if options and options.name then
    for _, animation in ipairs(self.animations) do
      if animation.options and animation.options.name == options.name then
        return
      end
    end
  end

  table.insert(self.animations, {
    target = target,
    properties = properties,
    options = options
  })
end

---Runs all registered animations removing duplicated and finished ones.
function Widget:run_animations()
  if #self.animations > 0 then
    ---@type table<widget.animation, widget.animation>
    local duplicates = {}

    local targets = {}
    local deleted = 0
    for i=1, #self.animations do
      local animation = self.animations[i - deleted]

      -- do not run animations that change same target to prevent conflicts.
      if not targets[animation.target] then
        local finished = true
        local options = animation.options or {}
        for name, value in pairs(animation.properties) do
          if animation.target[name] ~= value then
            self:move_towards(animation.target, name, value, options.rate)
            if options.on_step then
              options.on_step(animation.target, name, animation.target[name])
            end
            if animation.target[name] ~= value then
              finished = false
            end
          end
        end
        if finished then
          if options.on_complete then
            options.on_complete(self)
          end
          table.remove(self.animations, i - deleted)
          deleted = deleted + 1
        end
        targets[animation.target] = animation
      -- only registers it as duplicated if the animation does needs to
      -- perform any tasks on completion.
      elseif not targets[animation.target].on_complete then
        duplicates[targets[animation.target]] = animation
      end
    end

    -- remove older duplcated animations that modify same target and properties
    for duplicate, newer_animation in pairs(duplicates) do
      local exact_properties = true
      for name, _ in pairs(duplicate.properties) do
        if not newer_animation.properties[name] then
          exact_properties = false
          break
        end
      end
      if exact_properties then
        for name, _ in pairs(newer_animation.properties) do
          if not duplicate.properties[name] then
            exact_properties = false
            break
          end
        end
      end
      if exact_properties then
        for i, animation in ipairs(self.animations) do
          if animation == duplicate then
            table.remove(self.animations, i)
            break
          end
        end
      end
    end
  end
end

---If visible execute the widget calculations and returns true.
---@return boolean
function Widget:update()
  if not self:is_visible() then return false end

  Widget.super.update(self)

  -- call this to be able to properly scroll
  self:update_position()

  -- run any pending animations
  self:run_animations()

  for _, child in pairs(self.childs) do
    child:update()
  end

  return true
end

function Widget:draw_scrollbar()
  if self.scrollable then
    Widget.super.draw_scrollbar(self)
  end
end

---If visible draw the widget and returns true.
---@return boolean
function Widget:draw()
  if not self:is_visible() then return false end

  Widget.super.draw(self)

  self:draw_border()

  if self.render_background then
    if self.background_color then
      self:draw_background(self.background_color)
    else
      self:draw_background(
        self.parent and style.background or style.background2
      )
    end
  end

  if #self.childs > 0 then
    core.push_clip_rect(
      self.position.x,
      self.position.y,
      self.size.x,
      self.size.y
    )
  end

  for i=#self.childs, 1, -1 do
    self.childs[i]:draw()
  end

  if #self.childs > 0 then
    core.pop_clip_rect()
  end

  self:draw_scrollbar()

  return true
end

---Recursively destroy all childs from the widget.
function Widget:destroy_childs()
  for _=1, #self.childs do
    self.childs[1]:destroy_childs()
    table.remove(self.childs, 1)
  end
end

---If floating, remove the widget from the floating widgets list
---to allow proper garbage collection.
function Widget:destroy()
  if not self.parent or self.defer_draw then
    for idx, widget in ipairs(floating_widgets) do
      if widget == self then
        widget:destroy_childs()
        floating_widgets[idx] = nil
        table.remove(floating_widgets, idx)
        break
      end
    end
  end
end

---Flag that indicates if the rootview events are already overrided.
---@type boolean
local root_overrided = false

---Called when initializing a floating widget to generate RootView overrides,
---this function will only override the events once.
function Widget.override_rootview()
  if root_overrided then return end
  root_overrided = true

  local root_view_on_mouse_pressed = RootView.on_mouse_pressed
  local root_view_on_mouse_released = RootView.on_mouse_released
  local root_view_on_mouse_moved = RootView.on_mouse_moved
  local root_view_on_mouse_wheel = RootView.on_mouse_wheel
  local root_view_update = RootView.update
  local root_view_draw = RootView.draw
  local root_view_on_file_dropped = RootView.on_file_dropped
  local root_view_on_text_input = RootView.on_text_input

  function RootView:on_mouse_pressed(button, x, y, clicks)
    local pressed = false
    for i=#floating_widgets, 1, -1 do
      local widget = floating_widgets[i]
      if widget.visible then
        widget.mouse_pressed_outside = not widget:mouse_on_top(x, y)
        if
          (not widget.defer_draw and not widget.child_active)
          or
          widget.mouse_pressed_outside
          or
          (pressed or not widget:on_mouse_pressed(button, x, y, clicks))
        then
          widget:swap_active_child()
        else
          pressed = true
        end
      end
    end
    if not pressed then
      return root_view_on_mouse_pressed(self, button, x, y, clicks)
    else
      return true
    end
  end

  function RootView:on_mouse_released(button, x, y)
    local released = false
    for i=#floating_widgets, 1, -1 do
      local widget = floating_widgets[i]
      if widget.visible then
        if
          (not widget.defer_draw and not widget.child_active)
          or
          widget.mouse_pressed_outside
          or
          not widget:on_mouse_released(button, x, y)
        then
          widget.mouse_pressed_outside = false
        else
          released = true
        end
      end
    end
    if not released then
      root_view_on_mouse_released(self, button, x, y)
    end
  end

  function RootView:on_mouse_moved(x, y, dx, dy)
    local moved  = false
    if core.active_view ~= core.command_view then
      for i=#floating_widgets, 1, -1 do
        local widget = floating_widgets[i]
        if widget.visible then
          if
            (not widget.defer_draw and not widget.child_active)
            or
            widget.mouse_pressed_outside
            or
            (moved or not widget:on_mouse_moved(x, y, dx, dy))
          then
              if
                not widget.is_scrolling
                and
                not widget.child_active
                and
                widget.outside_view
              then
                core.set_active_view(widget.outside_view)
                widget.outside_view = nil
              end
          elseif not moved then
            if not widget.child_active and widget.defer_draw then
              if not widget.outside_view then
                widget.outside_view = core.active_view
              end
              core.set_active_view(widget)
              moved = true
            end
          end
        end
      end
    end
    if not moved then
      root_view_on_mouse_moved(self, x, y, dx, dy)
    end
  end

  function RootView:on_mouse_wheel(y, x)
    for i=#floating_widgets, 1, -1 do
      local widget = floating_widgets[i]
      if
        widget.visible and widget.defer_draw and widget:on_mouse_wheel(y, x)
      then
        return true
      end
    end
    return root_view_on_mouse_wheel(self, y, x)
  end

  function RootView:on_file_dropped(filename, x, y)
    for i=#floating_widgets, 1, -1 do
      local widget = floating_widgets[i]
      if
        widget.visible and widget.defer_draw
        and
        widget:on_file_dropped(filename, x, y)
      then
        return true
      end
    end
    return root_view_on_file_dropped(self, filename, x, y)
  end

  function RootView:on_text_input(text)
    for i=#floating_widgets, 1, -1 do
      local widget = floating_widgets[i]
      if
        widget.visible and widget.defer_draw and widget:on_text_input(text)
      then
        return true
      end
    end
    return root_view_on_text_input(self, text)
  end

  function RootView:update()
    root_view_update(self)
    local count = #floating_widgets
    for i=1, count, 1 do
      local widget = floating_widgets[i]
      if widget.visible and widget.defer_draw then
        widget:update()
      end
    end
  end

  function RootView:draw()
    local count = #floating_widgets
    for i=1, count, 1 do
      local widget = floating_widgets[i]
      if widget.visible and widget.defer_draw then
        core.root_view:defer_draw(widget.draw, widget)
      end
    end
    root_view_draw(self)
  end
end


return Widget
