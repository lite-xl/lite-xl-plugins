--
-- Extends core.scrollbar to allow propagating force status to child elements.
--

---@type core.scrollbar
local CoreScrollBar = require "core.scrollbar"

---@class widget.scrollbar : core.scrollbar
---@field super widget.scrollbar
---@field widget_parent widget
local ScrollBar = CoreScrollBar:extend()

function ScrollBar:new(parent, options)
  self.widget_parent = parent
  ScrollBar.super.new(self, options)
end

function ScrollBar:set_forced_status(status)
  ScrollBar.super.set_forced_status(self, status)
  if self.widget_parent and self.widget_parent.childs then
    for _, child in pairs(self.widget_parent.childs) do
      if self.direction == "v" then
        child.v_scrollbar:set_forced_status(status)
      else
        child.h_scrollbar:set_forced_status(status)
      end
    end
  end
end


return ScrollBar
