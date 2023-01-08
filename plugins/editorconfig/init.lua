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
local trimwhitespace = require "plugins.trimwhitespace"
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
  local editor_config = project_dir .. "/" .. ".editorconfig"
  local file = io.open(editor_config)
  if file then
    file:close()
    project_configs[project_dir] = Parser.new(editor_config)
    return true
  end
  return false
end

---Helper to add or substract final new line, it also makes final new line
---visble which lite-xl does not.
---@param doc core.doc
---@param raw? boolean If true does not register change on undo stack
---@return boolean handled_new_line
local function handle_final_new_line(doc, raw)
  local handled = false
  ---@diagnostic disable-next-line
  if doc.insert_final_newline then
    handled = true
    if doc.lines[#doc.lines] ~= "\n" then
      if not raw then
        doc:insert(#doc.lines, math.huge, "\n")
      else
        table.insert(doc.lines, "\n")
      end
    end
  ---@diagnostic disable-next-line
  elseif type(doc.insert_final_newline) == "boolean" then
    handled = true
    if trimwhitespace.trim_empty_end_lines then
      trimwhitespace.trim_empty_end_lines(doc, raw)
    -- TODO: remove this once 2.1.1 is released
    else
      for _=#doc.lines, 1, -1 do
        local l = #doc.lines
        if l > 1 and doc.lines[l] == "\n" then
          local current_line = doc:get_selection()
          if current_line == l then
            doc:set_selection(l-1, math.huge, l-1, math.huge)
          end
          if not raw then
            doc:remove(l-1, math.huge, l, math.huge)
          else
            table.remove(doc.lines, l)
          end
        end
      end
    end
  end
  return handled
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
---@param config_target? plugins.editorconfig.parser.section
---@param config_from? plugins.editorconfig.parser.section
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
  for path, editor_config in pairs(project_configs) do
    if common.path_belongs_to(file_path, path) then
      project_dir = path
      root_config = editor_config:getConfig(
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

  local editor_config = {}
  local config_found = false
  if not dir and root_config then
    editor_config = root_config
    config_found = true
  elseif dir then
    local path_list = split_path(dir)
    local root_found = false
    for p=#path_list, 1, -1 do
      local path = project_dir .. "/" .. table.concat(path_list, "/", 1, p)
      if file_exists(path .. "/" .. ".editorconfig") then
        ---@type plugins.editorconfig.parser
        local parser = Parser.new(path .. "/" .. ".editorconfig")
        local pconfig = parser:getConfig(common.relative_path(path, file_path))
        if pconfig then
          merge_config(editor_config, pconfig)
          config_found = true
        end
        if parser.root then
          root_found = true
          break
        end
      end
    end
    if not root_found and root_config then
      merge_config(editor_config, root_config)
      config_found = true
    end
  end

  -- clean unset options
  if config_found then
    local all_unset = true
    for name, value in pairs(editor_config) do
      if value == "unset" then
        editor_config[name] = nil
      else
        all_unset = false
      end
    end
    if all_unset then config_found = false end
  end

  return config_found and editor_config or nil
end

---Apply editorconfig rules to given doc if possible.
---@param doc core.doc
function editorconfig.apply(doc)
  if not doc.abs_filename and not doc.filename then return end
  local file_path = doc.abs_filename or (main_project .. "/" .. doc.filename)
  local options = recursive_get_config(file_path)
  if options then
    if config.plugins.editorconfig.debug then
      core.log_quiet(
        "[EditorConfig]: %s applied %s",
        file_path, common.serialize(options, {pretty = true})
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

    if options.indent_size and options.indent_size == "tab" then
      if options.tab_width then
        options.indent_size = options.tab_width
      else
        options.indent_size = config.indent_size or 2
      end
    end

    if options.indent_size then
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
    elseif options.trim_trailing_whitespace == false then
      doc.trim_trailing_whitespace = false
    else
      doc.trim_trailing_whitespace = nil
    end

    if options.insert_final_newline then
      doc.insert_final_newline = true
    elseif options.insert_final_newline == false then
      doc.insert_final_newline = false
    else
      doc.insert_final_newline = nil
    end

    if
      (
        type(doc.trim_trailing_whitespace) == "boolean"
        or
        type(doc.insert_final_newline) == "boolean"
      )
      -- TODO: remove this once 2.1.1 is released
      and
      trimwhitespace.disable
    then
      trimwhitespace.disable(doc)
    end

    handle_final_new_line(doc, true)
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
  local out = core_remove_project_directory(path)
  if project_configs[path] then project_configs[path] = nil end
  return out
end

local core_add_project_directory = core.add_project_directory
function core.add_project_directory(directory)
  local out = core_add_project_directory(directory)
  editorconfig.load(directory)
  return out
end

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
  if trimwhitespace.trim then
    trimwhitespace.trim(doc)
    return
  end

  -- TODO: remove this once 2.1.1 is released
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
  local new_file = self.new_file

  ---@diagnostic disable-next-line
  if self.trim_trailing_whitespace then
    trim_trailing_whitespace(self)
  end

  local lc = #self.lines
  local handle_new_line = handle_final_new_line(self)

  -- remove the unnecesary visible \n\n or the disabled \n
  if handle_new_line then
    self.lines[lc] = self.lines[lc]:gsub("\n$", "")
  end

  doc_save(self, ...)

  -- restore the visible \n\n or disabled \n
  if handle_new_line then
    self.lines[lc] = self.lines[lc] .. "\n"
  end

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
  elseif new_file then
    -- apply editorconfig options for file that was previously unsaved
    editorconfig.apply(self)
  end
end

--------------------------------------------------------------------------------
-- Run the test suite if requested on CLI with: lite-xl test editorconfig
--------------------------------------------------------------------------------
for i, argument in ipairs(ARGS) do
  if argument == "test" and ARGS[i+1] == "editorconfig" then
    require "plugins.editorconfig.runtest"
    os.exit()
  end
end


return editorconfig
