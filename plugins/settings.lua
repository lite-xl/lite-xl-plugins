-- mod-version:3 --priority:0
local core = require "core"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"
local keymap = require "core.keymap"
local style = require "core.style"
local Widget = require "widget"
local Label = require "widget.label"
local Line = require "widget.line"
local NoteBook = require "widget.notebook"
local Button = require "widget.button"
local TextBox = require "widget.textbox"
local SelectBox = require "widget.selectbox"
local NumberBox = require "widget.numberbox"
local Toggle = require "widget.toggle"
local ListBox = require "widget.listbox"
local FoldingBook = require "widget.foldingbook"
local ItemsList = require "widget.itemslist"
local ToolbarView = require "plugins.toolbarview"
local KeybindingDialog = require "widget.keybinddialog"

local settings = {}

settings.core = {}
settings.plugins = {}
settings.sections = {}
settings.plugin_sections = {}
settings.config = {}
settings.default_keybindings = {}

---Enumeration for the different types of settings.
---@type table<string, integer>
settings.type = {
  STRING = 1,
  NUMBER = 2,
  TOGGLE = 3,
  SELECTION = 4,
  LIST_STRINGS = 5,
  BUTTON = 6
}

---@alias settings.types
---|>'settings.type.STRING'
---| 'settings.type.NUMBER'
---| 'settings.type.TOGGLE'
---| 'settings.type.SELECTION'
---| 'settings.type.LIST_STRINGS'
---| 'settings.type.BUTTON'

---Represents a setting to render on a settings pane.
---@class settings.option
---@field public label string
---@field public description string
---@field public path string
---@field public type settings.types
---@field public default string | number | table<integer, string> | table<integer, integer>
---@field public min number
---@field public max number
---@field public step number
---@field public values table
---@field public get_value nil | fun(value:any):any
---@field public set_value nil | fun(value:any):any
---@field public icon string
---@field public on_click nil | string | fun(button:string, x:integer, y:integer)
---@field public on_apply nil | fun(value:any)
settings.option = {
  ---Title displayed to the user eg: "My Option"
  label = "",
  ---Description of the option eg: "Modifies the document indentation"
  description = "",
  ---Config path in the config table, eg: section.myoption, myoption, etc...
  path = "",
  ---Type of option that will be used to render an appropriate control
  type = "",
  ---Default value of the option
  default = "",
  ---Used for NUMBER to indiciate the minimum number allowed
  min = 0,
  ---Used for NUMBER to indiciate the maximum number allowed
  max = 0,
  ---Used for NUMBER to indiciate the increment/decrement amount
  step = 0,
  ---Used in a SELECTION to provide the list of valid options
  values = {},
  ---Optional function that is used to manipulate the current value on retrieval.
  get_value = nil,
  ---Optional function that is used to manipulate the saved value on save.
  set_value = nil,
  ---The icon set for a BUTTON
  icon = "",
  ---Command or function executed when a BUTTON is clicked
  on_click = nil,
  ---Optional function executed when the option value is applied.
  on_apply = nil
}

---Add a new settings section to the settings UI
---@param section string
---@param options settings.option[]
---@param plugin_name? string Optional name of plugin
---@param overwrite? boolean Overwrite previous section options
function settings.add(section, options, plugin_name, overwrite)
  local category = ""
  if plugin_name ~= nil then
    category = "plugins"
  else
    category = "core"
  end

  if overwrite and settings[category][section] then
    settings[category][section] = {}
  end

  if not settings[category][section] then
    settings[category][section] = {}
    if category ~= "plugins" then
      table.insert(settings.sections, section)
    else
      table.insert(settings.plugin_sections, section)
    end
  end

  if plugin_name ~= nil then
    if not settings[category][section][plugin_name] then
      settings[category][section][plugin_name] = {}
    end
    for _, option in ipairs(options) do
      table.insert(settings[category][section][plugin_name], option)
    end
  else
    for _, option in ipairs(options) do
      table.insert(settings[category][section], option)
    end
  end
end

--------------------------------------------------------------------------------
-- Add Core Settings
--------------------------------------------------------------------------------

settings.add("General",
  {
    {
      label = "User Module",
      description = "Open your init.lua for customizations.",
      type = settings.type.BUTTON,
      icon = "P",
      on_click = "core:open-user-module"
    },
    {
      label = "Maximum Project Files",
      description = "The maximum amount of project files to register.",
      path = "max_project_files",
      type = settings.type.NUMBER,
      default = 2000,
      min = 1,
      max = 100000,
      on_apply = function()
        core.rescan_project_directories()
      end
    },
    {
      label = "File Size Limit",
      description = "The maximum file size in megabytes allowed for editing.",
      path = "file_size_limit",
      type = settings.type.NUMBER,
      default = 10,
      min = 1,
      max = 50
    },
    {
      label = "Ignore Files",
      description = "List of lua patterns matching files to be ignored by the editor.",
      path = "ignore_files",
      type = settings.type.LIST_STRINGS,
      default = { "^%." },
      on_apply = function()
        core.rescan_project_directories()
      end
    },
    {
      label = "Maximum Clicks",
      description = "The maximum amount of consecutive clicks that are registered by the editor.",
      path = "max_clicks",
      type = settings.type.NUMBER,
      default = 3,
      min = 1,
      max = 10
    },
  }
)

settings.add("Graphics",
  {
    {
      label = "Frames Per Second",
      description = "Lower value for low end machines and higher for a smoother experience.",
      path = "fps",
      type = settings.type.NUMBER,
      default = 60,
      min = 10,
      max = 300
    },
    {
      label = "Transitions",
      description = "If disabled turns off all transitions but improves rendering performance.",
      path = "transitions",
      type = settings.type.TOGGLE,
      default = true
    },
    {
      label = "Animation Rate",
      description = "The amount of time it takes for a transition to finish.",
      path = "animation_rate",
      type = settings.type.NUMBER,
      default = 1.0,
      min = 0.5,
      max = 3.0,
      step = 0.1
    },
    {
      label = "Animate Mouse Drag Scroll",
      description = "Causes higher cpu usage but smoother scroll transition.",
      path = "animate_drag_scroll",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Scrolling Transitions",
      path = "disabled_transitions.scroll",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Command View Transitions",
      path = "disabled_transitions.commandview",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Context Menu Transitions",
      path = "disabled_transitions.contextmenu",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Log View Transitions",
      path = "disabled_transitions.logview",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Nag Bar Transitions",
      path = "disabled_transitions.nagbar",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Tab Transitions",
      path = "disabled_transitions.tabs",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Tab Drag Transitions",
      path = "disabled_transitions.tab_drag",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Disable Status Bar Transitions",
      path = "disabled_transitions.statusbar",
      type = settings.type.TOGGLE,
      default = false
    },
  }
)

settings.add("User Interface",
  {
    {
      label = "Borderless",
      description = "Use built-in window decorations.",
      path = "borderless",
      type = settings.type.TOGGLE,
      default = false,
      on_apply = function()
        core.configure_borderless_window()
      end
    },
    {
      label = "Messages Timeout",
      description = "The amount in seconds before a notification dissapears.",
      path = "message_timeout",
      type = settings.type.NUMBER,
      default = 5,
      min = 1,
      max = 30
    },
    {
      label = "Always Show Tabs",
      description = "Shows tabs even if a single document is opened.",
      path = "always_show_tabs",
      type = settings.type.TOGGLE,
      default = true
    },
    {
      label = "Maximum Tabs",
      description = "The maximum amount of visible document tabs.",
      path = "max_tabs",
      type = settings.type.NUMBER,
      default = 8,
      min = 1,
      max = 100
    },
    {
      label = "Close Button on Tabs",
      description = "Display the close button on tabs.",
      path = "tab_close_button",
      type = settings.type.TOGGLE,
      default = true
    },
    {
      label = "Mouse wheel scroll rate",
      description = "The amount to scroll when using the mouse wheel.",
      path = "mouse_wheel_scroll",
      type = settings.type.NUMBER,
      default = 50,
      min = 10,
      max = 200,
      get_value = function(value)
        return value / SCALE
      end,
      set_value = function(value)
        return value * SCALE
      end
    },
    {
      label = "Disable Cursor Blinking",
      description = "Disables cursor blinking on text input elements.",
      path = "disable_blink",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Cursor Blinking Period",
      description = "Interval in seconds in which the cursor blinks.",
      path = "blink_period",
      type = settings.type.NUMBER,
      default = 0.8,
      min = 0.3,
      max = 2.0,
      step = 0.1
    }
  }
)

settings.add("Editor",
  {
    {
      label = "Indentation Type",
      description = "The character inserted when pressing the tab key.",
      path = "tab_type",
      type = settings.type.SELECTION,
      default = "soft",
      values = {
        {"Space", "soft"},
        {"Tab", "hard"}
      }
    },
    {
      label = "Indentation Size",
      description = "Amount of spaces shown per indentation.",
      path = "indent_size",
      type = settings.type.NUMBER,
      default = 2,
      min = 1,
      max = 10
    },
    {
      label = "Line Limit",
      description = "Amount of characters at which the line breaking column will be drawn.",
      path = "line_limit",
      type = settings.type.NUMBER,
      default = 80,
      min = 1
    },
    {
      label = "Line Height",
      description = "The amount of spacing between lines.",
      path = "line_height",
      type = settings.type.NUMBER,
      default = 1.2,
      min = 1.0,
      max = 3.0,
      step = 0.1
    },
    {
      label = "Highlight Line",
      description = "Highlight the current line.",
      path = "highlight_current_line",
      type = settings.type.SELECTION,
      default = true,
      values = {
        {"Yes", true},
        {"No", false},
        {"No Selection", "no_selection"}
      },
      set_value = function(value)
        if type(value) == "nil" then return false end
        return value
      end
    },
    {
      label = "Maximum Undo History",
      description = "The amount of undo elements to keep.",
      path = "max_undos",
      type = settings.type.NUMBER,
      default = 10000,
      min = 100,
      max = 100000
    },
    {
      label = "Undo Merge Timeout",
      description = "Time in seconds before applying an undo action.",
      path = "undo_merge_timeout",
      type = settings.type.NUMBER,
      default = 0.3,
      min = 0.1,
      max = 1.0,
      step = 0.1
    },
    {
      label = "Show Spaces",
      description = "Draw another character in place of invisble spaces.",
      path = "draw_whitespace",
      type = settings.type.TOGGLE,
      default = false
    },
    {
      label = "Symbol Pattern",
      description = "A lua pattern used to match symbols in the document.",
      path = "symbol_pattern",
      type = settings.type.STRING,
      default = "[%a_][%w_]*"
    },
    {
      label = "Non Word Characters",
      description = "A string of characters that do not belong to a word.",
      path = "non_word_chars",
      type = settings.type.STRING,
      default = " \\t\\n/\\()\"':,.;<>~!@#$%^&*|+=[]{}`?-",
      get_value = function(value)
        return value:gsub("\n", "\\n"):gsub("\t", "\\t")
      end,
      set_value = function(value)
        return value:gsub("\\n", "\n"):gsub("\\t", "\t")
      end
    },
    {
      label = "Scroll Past the End",
      description = "Allow scrolling beyond the document ending.",
      path = "scroll_past_end",
      type = settings.type.TOGGLE,
      default = true
    }
  }
)

settings.add("Development",
  {
    {
      label = "Log Items",
      description = "The maximum amount of entries to keep on the log UI.",
      path = "max_log_items",
      type = settings.type.NUMBER,
      default = 80,
      min = 50,
      max = 2000
    },
    {
      label = "Skip Plugins Version",
      description = "Do not verify the plugins required versions at startup.",
      path = "skip_plugins_version",
      type = settings.type.TOGGLE,
      default = false
    }
  }
)

---Retrieve from given config the associated value using the given path.
---@param conf table
---@param path string
---@param default any
---@return any | nil
local function get_config_value(conf, path, default)
  local sections = {};
  for match in (path.."."):gmatch("(.-)%.") do
    table.insert(sections, match);
  end

  local element = conf
  for _, section in ipairs(sections) do
    if type(element[section]) ~= "nil" then
      element = element[section]
    else
      return default
    end
  end

  if type(element) == "nil" then
    return default
  end

  return element
end

---Loops the given config table using the given path and store the value.
---@param conf table
---@param path string
---@param value any
local function set_config_value(conf, path, value)
  local sections = {};
  for match in (path.."."):gmatch("(.-)%.") do
    table.insert(sections, match);
  end

  local sections_count = #sections

  if sections_count == 1 then
    conf[sections[1]] = value
    return
  elseif type(conf[sections[1]]) ~= "table" then
    conf[sections[1]] = {}
  end

  local element = conf
  for idx, section in ipairs(sections) do
    if type(element[section]) ~= "table" then
      element[section] = {}
      element = element[section]
    else
      element = element[section]
    end
    if idx + 1 == sections_count then break end
  end

  element[sections[sections_count]] = value
end

---Get a list of system and user installed plugins.
---@return table<integer, string>
local function get_installed_plugins()
  local files, ordered = {}, {}

  for _, root_dir in ipairs {DATADIR, USERDIR} do
    local plugin_dir = root_dir .. "/plugins"
    for _, filename in ipairs(system.list_dir(plugin_dir) or {}) do
      local valid = false
      local file_info = system.get_file_info(plugin_dir .. "/" .. filename)
      if
        file_info.type == "file"
        and
        filename:match("%.lua$")
        and
        not filename:match("^language_")
      then
        valid = true
        filename = filename:gsub("%.lua$", "")
      elseif file_info.type == "dir" then
        if system.get_file_info(plugin_dir .. "/" .. filename .. "/init.lua") then
          valid = true
        end
      end
      if valid then
        if not files[filename] then table.insert(ordered, filename) end
        files[filename] = true
      end
    end
  end

  table.sort(ordered)

  return ordered
end

---Get a list of system and user installed colors.
---@return table<integer, table>
local function get_installed_colors()
  local files, ordered = {}, {}

  for _, root_dir in ipairs {DATADIR, USERDIR} do
    local dir = root_dir .. "/colors"
    for _, filename in ipairs(system.list_dir(dir) or {}) do
      local file_info = system.get_file_info(dir .. "/" .. filename)
      if
        file_info.type == "file"
        and
        filename:match("%.lua$")
      then
        -- read colors
        local contents = io.open(dir .. "/" .. filename):read("*a")
        local colors = {}
        for r, g, b in contents:gmatch("#(%x%x)(%x%x)(%x%x)") do
          r = tonumber(r, 16)
          g = tonumber(g, 16)
          b = tonumber(b, 16)
          table.insert(colors, { r, g, b, 0xff })
        end
        -- sort colors from darker to lighter
        table.sort(colors, function(a, b)
          return a[1] + a[2] + a[3] < b[1] + b[2] + b[3]
        end)
        -- remove duplicate colors
        local b = {}
        for i = #colors, 1, -1 do
          local a = colors[i]
          if a[1] == b[1] and a[2] == b[2] and a[3] == b[3] then
            table.remove(colors, i)
          else
            b = colors[i]
          end
        end
        -- insert color to ordered table if not duplicate
        filename = filename:gsub("%.lua$", "")
        if not files[filename] then
          table.insert(ordered, {name = filename, colors = colors})
        end
        files[filename] = true
      end
    end
  end

  table.sort(ordered, function(a, b) return a.name < b.name end)

  return ordered
end

---Capitalize first letter of every word.
---Taken from core.command.
---@param words string
---@return string
local function capitalize_first(words)
  return words:sub(1, 1):upper() .. words:sub(2)
end

---Similar to command prettify_name but also takes care of underscores.
---@param name string
---@return string
local function prettify_name(name)
  return name:gsub("[%-_]", " "):gsub("%S+", capitalize_first)
end

---Load config options from the USERDIR user_settings.lua and store them on
---settings.config for later usage.
local function load_settings()
  local ok, t = pcall(dofile, USERDIR .. "/user_settings.lua")
  settings.config = ok and t.config or {}
end

---Save current config options into the USERDIR user_settings.lua
local function save_settings()
  local fp = io.open(USERDIR .. "/user_settings.lua", "w")
  if fp then
    local output = "{\n  [\"config\"] = "
      .. common.serialize(
        settings.config,
        { pretty = true, escape = true, sort = true, initial_indent = 1 }
      ):gsub("^%s+", "")
      .. "\n}\n"
    fp:write("return ", output)
    fp:close()
  end
end

---Apply a keybinding and optionally save it.
---@param cmd string
---@param bindings table<integer, string>
---@param skip_save? boolean
---@return table | nil
local function apply_keybinding(cmd, bindings, skip_save)
  local row_value = nil
  local changed = false

  local original_bindings = { keymap.get_binding(cmd) }
  for _, binding in ipairs(original_bindings) do
    keymap.unbind(binding, cmd)
  end

  if #bindings > 0 then
    if
      not skip_save
      and
      settings.config.custom_keybindings
      and
      settings.config.custom_keybindings[cmd]
    then
      settings.config.custom_keybindings[cmd] = {}
    end
    local shortcuts = ""
    for _, binding in ipairs(bindings) do
      if not binding:match("%+$") and binding ~= "" and binding ~= "none" then
        keymap.add({[binding] = cmd})
        shortcuts = shortcuts .. binding .. "\n"
        if not skip_save then
          if not settings.config.custom_keybindings then
            settings.config.custom_keybindings = {}
            settings.config.custom_keybindings[cmd] = {}
          elseif not settings.config.custom_keybindings[cmd] then
            settings.config.custom_keybindings[cmd] = {}
          end
          table.insert(settings.config.custom_keybindings[cmd], binding)
          changed = true
        end
      end
    end
    if shortcuts ~= "" then
      local bindings_list = shortcuts:gsub("\n$", "")
      row_value = {
        style.text, cmd, ListBox.COLEND, style.dim, bindings_list
      }
    end
  elseif
    not skip_save
    and
    settings.config.custom_keybindings
    and
    settings.config.custom_keybindings[cmd]
  then
    settings.config.custom_keybindings[cmd] = nil
    changed = true
  end

  if changed then
    save_settings()
  end

  if not row_value then
    row_value = {
      style.text, cmd, ListBox.COLEND, style.dim, "none"
    }
  end

  return row_value
end

---Merge previously saved settings without destroying the config table.
local function merge_settings()
  if type(settings.config) ~= "table" then return end

  -- merge core settings
  for _, section in ipairs(settings.sections) do
    local options = settings.core[section]
    for _, option in ipairs(options) do
      if type(option.path) == "string" then
        local saved_value = get_config_value(settings.config, option.path)
        if type(saved_value) ~= "nil" then
          set_config_value(config, option.path, saved_value)
          if option.on_apply then
            option.on_apply(saved_value)
          end
        end
      end
    end
  end

  -- merge plugin settings
  table.sort(settings.plugin_sections)
  for _, section in ipairs(settings.plugin_sections) do
    local plugins = settings.plugins[section]
    for plugin_name, options in pairs(plugins) do
      for _, option in pairs(options) do
        if type(option.path) == "string" then
          local path = "plugins." .. plugin_name .. "." .. option.path
          local saved_value = get_config_value(settings.config, path)
          if type(saved_value) ~= "nil" then
            set_config_value(config, path, saved_value)
            if option.on_apply then
              option.on_apply(saved_value)
            end
          end
        end
      end
    end
  end

  -- apply custom keybindings
  if settings.config.custom_keybindings then
    for cmd, bindings in pairs(settings.config.custom_keybindings) do
      apply_keybinding(cmd, bindings, true)
    end
  end
end

---Scan all plugins to check if they define a config_spec and load it.
local function scan_plugins_spec()
  for plugin, conf in pairs(config.plugins) do
    if type(conf) == "table" and conf.config_spec then
      settings.add(
        conf.config_spec.name,
        conf.config_spec,
        plugin
      )
    end
  end
end

---Called at core first run to store the default keybindings.
local function store_default_keybindings()
  for name, _ in pairs(command.map) do
    local keys = { keymap.get_binding(name) }
    if #keys > 0 then
      settings.default_keybindings[name] = keys
    end
  end
end

---@class settings.ui : widget
---@field private notebook widget.notebook
---@field private core widget
---@field private plugins widget
---@field private keybinds widget
---@field private core_sections widget.foldingbook
---@field private plugin_sections widget.foldingbook
local Settings = Widget:extend()

---Constructor
function Settings:new()
  Settings.super.new(self, false)

  self.name = "Settings"
  self.defer_draw = false
  self.border.width = 0
  self.draggable = false
  self.scrollable = false

  ---@type widget.notebook
  self.notebook = NoteBook(self)
  self.notebook.size.x = 250
  self.notebook.size.y = 300
  self.notebook.border.width = 0

  self.core = self.notebook:add_pane("core", "Core")
  self.colors = self.notebook:add_pane("colors", "Colors")
  self.plugins = self.notebook:add_pane("plugins", "Plugins")
  self.keybinds = self.notebook:add_pane("keybindings", "Keybindings")

  self.notebook:set_pane_icon("core", "P")
  self.notebook:set_pane_icon("colors", "W")
  self.notebook:set_pane_icon("plugins", "B")
  self.notebook:set_pane_icon("keybindings", "M")

  self.core_sections = FoldingBook(self.core)
  self.core_sections.border.width = 0
  self.core_sections.scrollable = false

  self.plugin_sections = FoldingBook(self.plugins)
  self.plugin_sections.border.width = 0
  self.plugin_sections.scrollable = false

  self:load_core_settings()
  self:load_color_settings()
  self:load_plugin_settings()
  self:load_keymap_settings()
end

---Helper function to add control for both core and plugin settings.
---@oaram pane widget
---@param option settings.option
---@param plugin_name? string | nil
local function add_control(pane, option, plugin_name)
  local found = false
  local path = type(plugin_name) ~= "nil" and
    "plugins." .. plugin_name .. "." .. option.path or option.path
  local option_value = nil
  if type(path) ~= "nil" then
    option_value = get_config_value(config, path, option.default)
  end

  if option.get_value then
    option_value = option.get_value(option_value)
  end

  ---@type widget
  local widget = nil

  if type(option.type) == "string" then
    option.type = settings.type[option.type:upper()]
  end

  if option.type == settings.type.NUMBER then
    ---@type widget.label
    Label(pane, option.label .. ":")
    ---@type widget.numberbox
    local number = NumberBox(pane, option_value, option.min, option.max, option.step)
    widget = number
    found = true

  elseif option.type == settings.type.TOGGLE then
    ---@type widget.toggle
    local toggle = Toggle(pane, option.label, option_value)
    widget = toggle
    found = true

  elseif option.type == settings.type.STRING then
    ---@type widget.label
    Label(pane, option.label .. ":")
    ---@type widget.textbox
    local string = TextBox(pane, option_value or "")
    widget = string
    found = true

  elseif option.type == settings.type.SELECTION then
    ---@type widget.label
    Label(pane, option.label .. ":")
    ---@type widget.selectbox
    local select = SelectBox(pane)
    for _, data in pairs(option.values) do
      select:add_option(data[1], data[2])
    end
    for idx, _ in ipairs(select.list.rows) do
      if select.list:get_row_data(idx) == option_value then
        select:set_selected(idx-1)
        break
      end
    end
    widget = select
    found = true

  elseif option.type == settings.type.BUTTON then
    ---@type widget.button
    local button = Button(pane, option.label)
    if option.icon then
      button:set_icon(option.icon)
    end
    if option.on_click then
      local command_type = type(option.on_click)
      if command_type == "string" then
        function button:on_click()
          command.perform(option.on_click)
        end
      elseif command_type == "function" then
        button.on_click = option.on_click
      end
    end
    widget = button
    found = true

  elseif option.type == settings.type.LIST_STRINGS then
     ---@type widget.label
    Label(pane, option.label .. ":")
    ---@type widget.itemslist
    local list = ItemsList(pane)
    if type(option_value) == "table" then
      for _, value in ipairs(option_value) do
        list:add_item(value)
      end
    end
    widget = list
    found = true
  end

  if widget and type(path) ~= "nil" then
    function widget:on_change(value)
      if self:is(SelectBox) then
        value = self:get_selected_data()
      elseif self:is(ItemsList) then
        value = self:get_items()
      end
      if option.set_value then
        value = option.set_value(value)
      end
      set_config_value(config, path, value)
      set_config_value(settings.config, path, value)
      save_settings()
      if option.on_apply then
        option.on_apply(value)
      end
    end
  end

  if (option.description or option.default) and found then
    local text = option.description or ""
    local default = ""
    local default_type = type(option.default)
    if default_type ~= "table" and default_type ~= "nil" then
      if text ~= "" then
        text = text .. " "
      end
      default = string.format("(default: %s)", option.default)
    end
     ---@type widget.label
    local description = Label(pane, text .. default)
    description.desc = true
  end
end

---Generate all the widgets for core settings.
function Settings:load_core_settings()
  for _, section in ipairs(settings.sections) do
    local options = settings.core[section]

    ---@type widget
    local pane = self.core_sections:get_pane(section)
    if not pane then
      pane = self.core_sections:add_pane(section, section)
    else
      pane = pane.container
    end

    for _, opt in ipairs(options) do
      ---@type settings.option
      local option = opt
      add_control(pane, option)
    end
  end
end

---Function in charge of rendering the colors column of the color pane.
---@param self widget.listbox
---@oaram row integer
---@param x integer
---@param y integer
---@param font renderer.font
---@param color renderer.color
---@param only_calc boolean
---@return number width
---@return number height
local function on_color_draw(self, row, x, y, font, color, only_calc)
  local w = self:get_width() - (x - self.position.x) - style.padding.x
  local h = font:get_height()

  if not only_calc then
    local row_data = self:get_row_data(row)
    local width = w/#row_data.colors

    for i = 1, #row_data.colors do
      renderer.draw_rect(x + ((i - 1) * width), y, width, h, row_data.colors[i])
    end
  end

  return w, h
end

---Generate the list of all available colors with preview
function Settings:load_color_settings()
  self.colors.scrollable = false

  local colors = get_installed_colors()

  ---@type widget.listbox
  local listbox = ListBox(self.colors)

  listbox.border.width = 0
  listbox:enable_expand(true)

  listbox:add_column("Theme")
  listbox:add_column("Colors")

  for idx, details in ipairs(colors) do
    local name = details.name
    if settings.config.theme and settings.config.theme == name then
      listbox:set_selected(idx)
    end
    listbox:add_row({
      style.text, name, ListBox.COLEND, on_color_draw
    }, {name = name, colors = details.colors})
  end

  function listbox:on_row_click(idx, data)
    core.reload_module("colors." .. data.name)
    settings.config.theme = data.name
    save_settings()
  end
end

---Unload a plugin settings from plugins section.
---@param plugin string
function Settings:disable_plugin(plugin)
  for _, section in ipairs(settings.plugin_sections) do
    local plugins = settings.plugins[section]

    for plugin_name, options in pairs(plugins) do
      if plugin_name == plugin then
        self.plugin_sections:delete_pane(section)
      end
    end
  end

  if
    type(settings.config.enabled_plugins) == "table"
    and
    settings.config.enabled_plugins[plugin]
  then
    settings.config.enabled_plugins[plugin] = nil
  end
  if type(settings.config.disabled_plugins) ~= "table" then
    settings.config.disabled_plugins = {}
  end

  settings.config.disabled_plugins[plugin] = true
  save_settings()
end

---Load plugin and append its settings to the plugins section.
---@param plugin string
function Settings:enable_plugin(plugin)
  local loaded = false
  local config_type = type(config.plugins[plugin])
  if config_type == "boolean" or config_type == "nil" then
    config.plugins[plugin] = {}
    loaded = true
  end

  require("plugins." .. plugin)

  if config.plugins[plugin] and config.plugins[plugin].config_spec then
    local conf = config.plugins[plugin].config_spec
    settings.add(conf.name, conf, plugin, true)
  end

  for _, section in ipairs(settings.plugin_sections) do
    local plugins = settings.plugins[section]

    for plugin_name, options in pairs(plugins) do
      if plugin_name == plugin then
        ---@type widget
        local pane = self.plugin_sections:get_pane(section)
        if not pane then
          pane = self.plugin_sections:add_pane(section, section)
        else
          pane = pane.container
        end

        for _, opt in ipairs(options) do
          ---@type settings.option
          local option = opt
          add_control(pane, option, plugin_name)
        end
      end
    end
  end

  if
    type(settings.config.disabled_plugins) == "table"
    and
    settings.config.disabled_plugins[plugin]
  then
    settings.config.disabled_plugins[plugin] = nil
  end
  if type(settings.config.enabled_plugins) ~= "table" then
    settings.config.enabled_plugins = {}
  end

  settings.config.enabled_plugins[plugin] = true
  save_settings()

  if loaded then
    core.log("Loaded '%s' plugin", plugin)
  end
end

---Generate all the widgets for plugin settings.
function Settings:load_plugin_settings()
  ---@type widget
  local pane = self.plugin_sections:get_pane("enable_disable")
  if not pane then
    pane = self.plugin_sections:add_pane("enable_disable", "Installed")
  else
    pane = pane.container
  end

  -- requires earlier access to startup process
  Label(
    pane,
    "Notice: disabling plugins will not take effect until next restart"
  )

  Line(pane, 2, 10)

  local plugins = get_installed_plugins()
  for _, plugin in ipairs(plugins) do
    if plugin ~= "settings" then
      local enabled = false

      if
        (
          type(config.plugins[plugin]) ~= "nil"
          and
          config.plugins[plugin] ~= false
        )
        or
        (
          settings.config.enabled_plugins
          and
          settings.config.enabled_plugins[plugin]
        )
      then
        enabled = true
      end

      local this = self

      ---@type widget.toggle
      local toggle = Toggle(pane, prettify_name(plugin), enabled)
      function toggle:on_change(value)
        if value then
          this:enable_plugin(plugin)
        else
          this:disable_plugin(plugin)
        end
      end
    end
  end

  table.sort(settings.plugin_sections)

  for _, section in ipairs(settings.plugin_sections) do
    local plugins = settings.plugins[section]

    for plugin_name, options in pairs(plugins) do
      ---@type widget
      local pane = self.plugin_sections:get_pane(section)
      if not pane then
        pane = self.plugin_sections:add_pane(section, section)
      else
        pane = pane.container
      end

      for _, opt in ipairs(options) do
        ---@type settings.option
        local option = opt
        add_control(pane, option, plugin_name)
      end
    end
  end
end

---@type widget.keybinddialog
local keymap_dialog = KeybindingDialog()

function keymap_dialog:on_save(bindings)
  local row_value = apply_keybinding(self.command, bindings)
  if row_value then
    self.listbox:set_row(self.row_id, row_value)
  end
end

function keymap_dialog:on_reset()
  local default_keys = settings.default_keybindings[self.command]
  local current_keys = { keymap.get_binding(self.command) }

  for _, binding in ipairs(current_keys) do
    keymap.unbind(binding, self.command)
  end

  if default_keys and #default_keys > 0 then
    local cmd = self.command
    if not settings.config.custom_keybindings then
      settings.config.custom_keybindings = {}
      settings.config.custom_keybindings[cmd] = {}
    elseif not settings.config.custom_keybindings[cmd] then
      settings.config.custom_keybindings[cmd] = {}
    end
    local shortcuts = ""
    for _, binding in ipairs(default_keys) do
      keymap.add({[binding] = cmd})
      shortcuts = shortcuts .. binding .. "\n"
      table.insert(settings.config.custom_keybindings[cmd], binding)
    end
    local bindings_list = shortcuts:gsub("\n$", "")
    self.listbox:set_row(self.row_id, {
      style.text, cmd, ListBox.COLEND, style.dim, bindings_list
    })
  else
    self.listbox:set_row(self.row_id, {
      style.text, self.command, ListBox.COLEND, style.dim, "none"
    })
  end
  if
    settings.config.custom_keybindings
    and
    settings.config.custom_keybindings[self.command]
  then
    settings.config.custom_keybindings[self.command] = nil
    save_settings()
  end
end

---Generate the list of all available commands and allow editing their keymaps.
function Settings:load_keymap_settings()
  self.keybinds.scrollable = false

  local ordered = {}
  for name, _ in pairs(command.map) do
    table.insert(ordered, name)
  end
  table.sort(ordered)

  ---@type widget.listbox
  local listbox = ListBox(self.keybinds)

  listbox.border.width = 0
  listbox:enable_expand(true)

  listbox:add_column("Command")
  listbox:add_column("Bindings")

  for _, name in ipairs(ordered) do
    local keys = { keymap.get_binding(name) }
    local binding = ""
    if #keys == 1 then
      binding = keys[1]
    elseif #keys > 1 then
      binding = keys[1]
      for idx, key in ipairs(keys) do
        if idx ~= 1 then
          binding = binding .. "\n" .. key
        end
      end
    elseif #keys < 1 then
      binding = "none"
    end
    listbox:add_row({
      style.text, name, ListBox.COLEND, style.dim, binding
    }, name)
  end

  function listbox:on_row_click(idx, data)
    if not keymap_dialog:is_visible() then
      local bindings = { keymap.get_binding(data) }
      keymap_dialog:set_bindings(bindings)
      keymap_dialog.row_id = idx
      keymap_dialog.command = data
      keymap_dialog.listbox = self
      keymap_dialog:show()
    end
  end
end

---Reposition and resize core and plugin widgets.
function Settings:update()
  if not Settings.super.update(self) then return end

  self.notebook:set_size(self.size.x, self.size.y)

  self.core:set_size(
    self.size.x,
    self.size.y - self.notebook.active_pane.tab:get_height() - 8
  )

  self.plugins:set_size(
    self.size.x,
    self.size.y - self.notebook.active_pane.tab:get_height() - 8
  )

  self.core_sections:set_size(
    self.core.size.x - (style.padding.x),
    self.core_sections:get_real_height()
  )

  self.plugin_sections:set_size(
    self.plugins.size.x - (style.padding.x),
    self.plugin_sections:get_real_height()
  )

  self.core_sections:set_position(
    style.padding.x / 2,
    0
  )

  self.plugin_sections:set_position(
    style.padding.x / 2,
    0
  )

  for _, section in ipairs({self.core_sections, self.plugin_sections}) do
    for _, pane in ipairs(section.panes) do
      local prev_child = nil
      for pos=#pane.container.childs, 1, -1 do
        local child = pane.container.childs[pos]
        local x, y = 10, 10
        if prev_child then
          if
            (prev_child:is(Label) and not prev_child.desc)
            or
            (child:is(Label) and child.desc)
          then
            y = prev_child:get_bottom() + 10
          else
            y = prev_child:get_bottom() + 40
          end
        end
        if child:is(Line) then
          x = 0
        elseif child:is(ItemsList) then
          child:set_size(pane.container:get_width() - 20, child.size.y)
        end
        child:set_position(x, y)
        prev_child = child
      end
    end
  end
end

--------------------------------------------------------------------------------
-- overwrite core run to inject previously saved settings
--------------------------------------------------------------------------------
local core_run = core.run
function core.run()
  store_default_keybindings()

  -- append all settings defined in the plugins spec
  scan_plugins_spec()

  -- merge custom settings into config
  merge_settings()

  ---@type settings.ui
  settings.ui = Settings()

  -- load plugins disabled by default and enabled by user
  if settings.config.enabled_plugins then
    for name, _ in pairs(settings.config.enabled_plugins) do
      if
        type(config.plugins[name]) == "boolean"
        and
        not config.plugins[name]
      then
        settings.ui:enable_plugin(name)
      end
    end
  end

  -- apply user chosen color theme
  if settings.config.theme then
    core.reload_module("colors." .. settings.config.theme)
  end

  core_run()
end

--------------------------------------------------------------------------------
-- Disable plugins at startup, only works if this file is the first
-- required on user module, or priority tag is obeyed by lite-xl.
--------------------------------------------------------------------------------
-- load custom user settings that include list of disabled plugins
load_settings()

-- only disable non already loaded plugins
if settings.config.disabled_plugins then
  for name, _ in pairs(settings.config.disabled_plugins) do
    if type(rawget(config.plugins, name)) == "nil" then
      config.plugins[name] = false
    end
  end
end

--------------------------------------------------------------------------------
-- Add command and keymap to load settings view
--------------------------------------------------------------------------------
command.add(nil, {
  ["ui:settings"] = function()
    settings.ui:show()
    local node = core.root_view:get_active_node_default()
    local found = false
    for _, view in ipairs(node.views) do
      if view == settings.ui then
        found = true
        node:set_active_view(view)
        break
      end
    end
    if not found then
      node:add_view(settings.ui)
    end
  end,
})

keymap.add {
  ["ctrl+alt+p"] = "ui:settings"
}

--------------------------------------------------------------------------------
-- Overwrite toolbar preferences command to open the settings gui
--------------------------------------------------------------------------------
local toolbarview_on_mouse_moved = ToolbarView.on_mouse_moved
function ToolbarView:on_mouse_moved(px, py, ...)
  toolbarview_on_mouse_moved(self, px, py, ...)
  if
    self.hovered_item
    and
    self.hovered_item.command == "core:open-user-module"
  then
    self.hovered_item.command = "ui:settings"
  end
end


return settings;
