--mod-version:3

local core = require 'core'
local config = require 'core.config'
local common = require 'core.common'
local command = require 'core.command'
local keymap = require 'core.keymap'
local style = require 'core.style'

local Doc = require 'core.doc'
local CommandView = require 'core.commandview'
local DocView = require 'core.docview'
local StatusView = require 'core.statusview'

config.plugins.overwrite = common.merge({ enabled = true }, config.plugins.overwrite)
local ovr_conf = config.plugins.overwrite

local overwrite = false

local s_installed = pcall(require, 'plugins.settings')
if s_installed then
	ovr_conf.config_spec = {
		name = "Overwrite",
		{
			label = "Enabled",
			type = "toggle",
			default = true,
			path = "enabled",
		}
	}
end

local d_text_input = Doc.text_input
function Doc:text_input(text, ...)
	if ovr_conf.enabled and overwrite and #text:gsub('\n', '') ~= 0 then
		for _, l, c in self:get_selections() do
			if self:get_char(l, c) ~= '\n' then
				self:remove(l, c, l, c+1)
			end
		end
	end

	return d_text_input(self, text, ...)
end

core.status_view:add_item {
	predicate = function()
		return  core.active_view:is(DocView)
		and not core.active_view:is(CommandView)
	end,
	name = "overwrite:state",
	alignment = StatusView.Item.RIGHT,
	get_item = function()
		if not ovr_conf.enabled then return {} end
		return {
			style.text, style.font,
			overwrite and "OVR" or "INS"
		}
	end,
	tooltip = "text editing mode",
	command = "overwrite:toggle",
	separator = StatusView.separator2,
}

command.add("core.docview!", {
	["overwrite:toggle"] = function() overwrite = not overwrite end
})

keymap.add { ["insert"] = "overwrite:toggle" }
