-- mod-version:3
--
-- EditorConfig plugin for Lite XL
-- @copyright Jefferson Gonzalez <jgmdev@gmail.com>
-- @license MIT
--
-- Note: this plugin needs to be loaded after detectindent plugin,
-- since the name editorconfig.lua is ordered after detectindent.lua
-- there shouldn't be any issues. Just a reminder for the future in
-- case of a plugin that could also handle document identation type
-- and size, and has a name with more weight than this plugin.
--
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local Doc = require "core.doc"
local Parser = require "plugins.editorconfig.parser"

---@class config.plugins.editorconfig
---@field debug boolean
config.plugins.editorconfig = common.merge({
  debug = false,
  -- The config specification used by the settings gui
  config_spec = {
    name = "EditorConfig",
    {
      label = "Debug",
      description = "Display debugging messages on the log.",
      path = "debug",
      type = "toggle",
      default = false
    }
  }
}, config.plugins.editorconfig)

---Cache of .editorconfig options to reduce parsing for every opened file.
---@type table<string, plugins.editorconfig.parser>
local project_configs = {}

---Keep track of main project directory so when changed we can assign a new
---.editorconfig object if neccesary.
---@type string
local main_project = core.project_dir

---Functionality that will be exposed by the plugin.
---@class plugins.editorconfig
local editorconfig = {}

---Load global .editorconfig options for a project.
---@param project_dir string
---@return boolean loaded
function editorconfig.load(project_dir)
  local config = project_dir .. "/" .. ".editorconfig"
  local file = io.open(config)
  if file then
    file:close()
    project_configs[project_dir] = Parser(config)
    return true
  end
  return false
end

---Split the given relative path by / or \ separators.
---@param path string The path to split
---@return table
local function split_path(path)
  local result = {};
  for match in (path.."/"):gmatch("(.-)".."[\\/]") do
    table.insert(result, match);
  end
  return result;
end

---Check if the given file path exists.
---@param file_path string
local function file_exists(file_path)
  local file = io.open(file_path, "r")
  if not file then return false end
  file:close()
  return true
end

---Merge a config options to target if they don't already exists on target.
---@param config_target plugins.editorconfig.parser.section?
---@param config_from plugins.editorconfig.parser.section?
local function merge_config(config_target, config_from)
  if config_target and config_from then
    for name, value in pairs(config_from) do
      if type(config_target[name]) == "nil" then
        config_target[name] = value
      end
    end
  end
end

---Scan for .editorconfig files from current file path to upper project path
---if root attribute is not found first and returns matching config.
---@param file_path string
---@return plugins.editorconfig.parser.section?
local function recursive_get_config(file_path)
  local project_dir = ""

  local root_config
  for path, config in pairs(project_configs) do
    if common.path_belongs_to(file_path, path) then
      project_dir = path
      root_config = config:getConfig(
        common.relative_path(path, file_path)
      )
      break
    end
  end

  if project_dir == "" then
    for _, project in ipairs(core.project_directories) do
      if common.path_belongs_to(file_path, project.name) then
        project_dir = project.name
        break
      end
    end
  end

  local relative_file_path = common.relative_path(project_dir, file_path)
  local dir = common.dirname(relative_file_path)

  local config = {}
  local config_found = false
  if not dir and root_config then
    config = root_config
    config_found = true
  elseif dir then
    local path_list = split_path(dir)
    local root_found = false
    for p=#path_list, 1, -1 do
      local path = project_dir .. "/" .. table.concat(path_list, "/", 1, p)
      if file_exists(path .. "/" .. ".editorconfig") then
        ---@type plugins.editorconfig.parser
        local parser = Parser(path .. "/" .. ".editorconfig")
        local pconfig = parser:getConfig(common.relative_path(path, file_path))
        if pconfig then
          merge_config(config, pconfig)
          config_found = true
        end
        if parser.root then
          root_found = true
          break
        end
      end
    end
    if not root_found and root_config then
      merge_config(config, root_config)
      config_found = true
    end
  end
  return config_found and config or nil
end

---Apply editorconfig rules to given doc if possible.
---@param doc core.doc
function editorconfig.apply(doc)
  if not doc.abs_filename then return end
  local options = recursive_get_config(doc.abs_filename)
  if options then
    if config.plugins.editorconfig.debug then
      core.log(
        "[EditorConfig]: %s applied %s",
        doc.abs_filename, common.serialize(options, {pretty = true})
      )
    end
    local indent_type, indent_size = doc:get_indent_info()
    if options.indent_style then
      if options.indent_style == "tab" then
        indent_type = "hard"
      else
        indent_type = "soft"
      end
    end

    if indent_type == "hard" and options.tab_width then
      indent_size = options.tab_width
    elseif options.indent_size then
      indent_size = options.indent_size
    end

    if doc.indent_info then
      doc.indent_info.type = indent_type
      doc.indent_info.size = indent_size
      doc.indent_info.confirmed = true
    else
      doc.indent_info = {
        type = indent_type,
        size = indent_size,
        confirmed = true
      }
    end

    if options.end_of_line then
      if options.end_of_line == "crlf" then
        doc.crlf = true
      elseif options.end_of_line == "lf" then
        doc.crlf = false
      end
    end

    if options.trim_trailing_whitespace then
      doc.trim_trailing_whitespace = true
    else
      doc.trim_trailing_whitespace = nil
    end

    if options.insert_final_newline then
      doc.insert_final_newline = true
    else
      doc.insert_final_newline = nil
    end
  end
end

---Applies .editorconfig options to all open documents if possible.
function editorconfig.apply_all()
  for _, doc in ipairs(core.docs) do
    editorconfig.apply(doc)
  end
end

--------------------------------------------------------------------------------
-- Load .editorconfig on all projects loaded at startup and apply it
--------------------------------------------------------------------------------
core.add_thread(function()
  local loaded = false

  -- scan all opened project directories
  if core.project_directories then
    for i=1, #core.project_directories do
      local found = editorconfig.load(core.project_directories[i].name)
      if found then loaded = true end
    end
  end

  -- if an editorconfig was found then try to apply it to opened docs
  if loaded then
    editorconfig.apply_all()
  end
end)

--------------------------------------------------------------------------------
-- Override various core project loading functions for .editorconfig scanning
--------------------------------------------------------------------------------
local core_open_folder_project = core.open_folder_project
function core.open_folder_project(directory)
  core_open_folder_project(directory)
  if project_configs[main_project] then project_configs[main_project] = nil end
  main_project = core.project_dir
  editorconfig.load(main_project)
end

local core_remove_project_directory = core.remove_project_directory
function core.remove_project_directory(path)
  core_remove_project_directory(path)
  if project_configs[path] then project_configs[path] = nil end
end

-- delay this override because otherwise causes startup issues due to yielding.
core.add_thread(function()
  local core_add_project_directory = core.add_project_directory
  function core.add_project_directory(directory)
    core_add_project_directory(directory)
    editorconfig.load(directory)
  end
end)

--------------------------------------------------------------------------------
-- Hook into the core.doc to apply editor config options
--------------------------------------------------------------------------------
local doc_new = Doc.new
function Doc:new(...)
  doc_new(self, ...)
  editorconfig.apply(self)
end

---Cloned trimwitespace plugin until it is exposed for other plugins.
---@param doc core.doc
local function trim_trailing_whitespace(doc)
  local cline, ccol = doc:get_selection()
  for i = 1, #doc.lines do
    local old_text = doc:get_text(i, 1, i, math.huge)
    local new_text = old_text:gsub("%s*$", "")

    -- don't remove whitespace which would cause the caret to reposition
    if cline == i and ccol > #new_text then
      new_text = old_text:sub(1, ccol - 1)
    end

    if old_text ~= new_text then
      doc:insert(i, 1, new_text)
      doc:remove(i, #new_text + 1, i, math.huge)
    end
  end
end

local doc_save = Doc.save
function Doc:save(...)
  ---@diagnostic disable-next-line
  if self.trim_trailing_whitespace then
    trim_trailing_whitespace(self)
  end

  ---@diagnostic disable-next-line
  if self.insert_final_newline then
    local newline = self.crlf and "\r\n" or "\n"
    if self.lines[#self.lines] ~= "\n" then
      table.insert(self.lines, newline)
    end
  end

  doc_save(self, ...)

  if common.basename(self.abs_filename) == ".editorconfig" then
    -- blindlessly reload related project .editorconfig options
    for _, project in ipairs(core.project_directories) do
      if common.path_belongs_to(self.abs_filename, project.name) then
        editorconfig.load(project.name)
        break
      end
    end
    -- re-apply editorconfig options to all open files
    editorconfig.apply_all()
  end
end


return editorconfig