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
	for i=1, 8 do self.fonts[i] = renderer.font.load(path, (12+i*7)*SCALE) end
	self.scrollable = true
end

function FontView:get_h_scrollable_size()
	return self.fonts[#self.fonts]:get_width(font_text) + style.padding.x
end

function FontView:get_scrollable_size() return 0 end

function FontView:get_name()
	return "Font: " .. self.path
end

local function draw_next_row(fv, y, text, font)
	local _
	_, y = common.draw_text(
		font, style.text, text, "left",
		fv.position.x - fv.scroll.x + style.padding.x, y - fv.scroll.y,
		0, style.padding.y + font:get_height() / 2
	)
	return y
end

function FontView:draw()
	self:draw_background(style.background)

	local y = self.position.y + self.fonts[1]:get_height() / 2 + style.padding.y

	for i=1, #self.fonts do
		y = draw_next_row(self, y, font_text, self.fonts[i])
	end

	local font = self.fonts[1]
	y = draw_next_row(self, y, "abcdefghijklmnopqrstuvwxyz", font)
	y = draw_next_row(self, y, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", font)
	y = draw_next_row(self, y, "0123456789", font)
	y = draw_next_row(self, y, "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~", font)

	self:draw_scrollbar()
end

local supported_types = { "%.ttf$", "%.otf$" }

local RootView = require 'core.rootview'
local open_doc = RootView.open_doc
function RootView:open_doc(doc)
	local path = doc.filename or doc.abs_filename or ""

	for _, v in ipairs(supported_types) do
		if path:find(v) then
			local node = self:get_active_node_default()
			local view = FontView(path)
			node:add_view(view)
			self.root_node:update_layout()
			return view
		end
	end

	return open_doc(self, doc)
end
