--mod-version:3 --priority:110

local common = require 'core.common'
local style = require 'core.style'
local View = require 'core.view'

local FontView = View:extend()

local font_text = "The quick brown fox jumps over the lazy dog."

function FontView:new(path)
	FontView.super.new(self)
	self.path = path
	self.fonts = {}
	for i=1, 8 do self.fonts[i] = renderer.font.load(path, 12+i*7) end
	self.scrollable = true
end

function FontView:get_h_scrollable_size()
	return self.fonts[#self.fonts]:get_width(font_text) + style.padding.x
end

function FontView:get_scrollable_size()
	return math.huge
end

function FontView:get_name()
	return "Font: " .. self.path
end

function FontView:draw()
	self:draw_background(style.background)

	local y = self.position.y + self.fonts[1]:get_height() / 2 + style.padding.y
	local y2 = y
	for i=1, #self.fonts do
		local font = self.fonts[i]
		local _
		_, y = common.draw_text(
			font, style.text, font_text, "left",
			self.position.x - self.scroll.x + style.padding.x, y - self.scroll.y,
			0, style.padding.y
		)
		y = y + font:get_height() / 2
	end

	self:draw_scrollbar()
end

local RootView = require 'core.rootview'
local open_doc = RootView.open_doc
function RootView:open_doc(doc)
	local path = doc.filename or doc.abs_filename or ""
	if path:find(".ttf") then
		local node = self:get_active_node_default()
		local view = FontView(path)
		node:add_view(view)
		self.root_node:update_layout()
		return view
	else
		open_doc(self, doc)
	end
end
