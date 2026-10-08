-- mod-version:3
-- original implementation by Titousensei
local core = require "core"
local config = require "core.config"
local common = require "core.common"
local style = require "core.style"
local CommandView = require "core.commandview"
local DocView = require "core.docview"
local StatusView = require "core.statusview"

config.plugins.countselected = common.merge({
  enabled = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Count Selected",
    {
      label = "Enabled",
      description = "Count selected characters and line in the status bar.",
      path = "enabled",
      type = "toggle",
      default = true,
      on_apply = function(enabled)
        core.add_thread(function()
          if enabled then
            core.status_view:get_item("status:count-selected"):show()
          else
            core.status_view:get_item("status:count-selected"):hide()
          end
        end)
      end
    }
  }
}, config.plugins.countselected)

core.status_view:add_item({
  predicate = function() return core.active_view:is(DocView) and not core.active_view:is(CommandView) end,
  name = "status:count-selected",
  alignment = StatusView.Item.RIGHT,
  get_item = function()
    local text_selected = core.active_view.doc:get_selection_text()
    local _, count_lf = text_selected:gsub("\n","")
    local plural = count_lf > 0 and "s" or ""
    return {
      style.text,
      string.format("Selected: %d char, %d line%s", #text_selected, count_lf + 1, plural)
    }
  end,
  position = 1,
  tooltip = "selected characters and lines",
  separator = core.status_view.separator2
})
