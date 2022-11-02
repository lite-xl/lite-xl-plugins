-- mod-version:3
local core = require "core"
local command = require "core.command"
local common = require "core.common"
local style = require "core.style"
local CommandView = require "core.commandview"

-- ----------------------------------------------------------------
local PATH_CONFIG = USERDIR .. "/color_settings.lua"

local Settings = {}
Settings.color_scheme = ""
Settings.color_list = {}
local color_default = {name = "Default", module = "core.style"}
local plugin_enable = false

--  =========================Proxy method==========================
local move_suggestion_idx = CommandView.move_suggestion_idx

function CommandView:move_suggestion_idx(dir)
  move_suggestion_idx(self, dir)
  if plugin_enable then
    local color_name = self.suggestions[self.suggestion_idx].text
    Settings:change_color(color_name)
  end
end

local on_quit_project = core.on_quit_project

function core.on_quit_project()
  Settings:save_settings()
  on_quit_project()
end
-- ----------------------------------------------------------------

function Settings:get_color_list()
  return self.color_list
end

function Settings:init()
  self:load_settings()
  self:make_color_list()
end

function Settings:make_color_list()
  for _, root_dir in ipairs {DATADIR, USERDIR} do
    local plugin_dir = root_dir .. "/colors"
    for _, filename in ipairs(system.list_dir(plugin_dir) or {}) do
      table.insert(self.color_list, filename:match("(.-)%.lua$"))
    end
  end
  table.insert(self.color_list, color_default.name)
end

function Settings:is_change_color(color_name)
  return not (self.color_scheme == color_name)
end

function Settings:get_color_scheme()
  return (self.color_scheme == "") and color_default.name or self.color_scheme
end

local function make_color_module_name(name)
  return (name == color_default.name) and color_default.module or "colors."..name
end

function Settings:change_color(name)
  if self:is_change_color(name) then
    core.reload_module(make_color_module_name(name))
    self.color_scheme = name
  end
end

function Settings:save_settings()
  local fp = io.open(PATH_CONFIG, "w")
  if fp then
    fp:write(self.color_scheme)
    fp:close()
  end
end

function Settings:load_settings()
  local fp = io.open(PATH_CONFIG, "r")
  if fp then
    local name = fp:read("*a")
    if name and name ~= "" then
      core.reload_module(make_color_module_name(name))
      Settings.color_scheme = name
    end
    fp:close()
  end
end

-- -------------------------------Utility--------------------------
local function table_remove_value(list, value)
  for i=1, #list do
    if list[i] == value then
      table.remove(list, i)
      break
    end
  end
end
-- ----------------------------------------------------------------
local function normalize_color_list(list)
  table_remove_value(list, Settings:get_color_scheme())
  table.sort(list, function(a, b) return string.lower(a) > string.lower(b) end)
  return {Settings:get_color_scheme(), table.unpack(list)}
end
--  =========================Add Commands==========================
local color_scheme_submit = function(text, item)
  if item then
    Settings:change_color(item.text)
    plugin_enable = false
  end
end

local color_scheme_suggest = function(text)
  plugin_enable = true
  local res_list = common.fuzzy_match(Settings:get_color_list(), text)
  return normalize_color_list(res_list)
end

command.add(nil, {
  ["ui:color scheme"] = function()
    core.command_view:enter("Select color scheme", {
      submit = color_scheme_submit, suggest = color_scheme_suggest
    })
  end,
})
-- ----------------------------------------------------------------

Settings:init()
