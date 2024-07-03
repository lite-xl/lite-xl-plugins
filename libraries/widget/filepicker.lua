local core = require "core"
local common = require "core.common"
local style = require "core.style"
local Widget = require "libraries.widget"
local Button = require "libraries.widget.button"
local Label = require "libraries.widget.label"

---@class widget.filepicker : widget
---@field public pick_mode integer
---@field public filters table<integer,string>
---@field private path string
---@field private file widget.label
---@field private textbox widget.textbox
---@field private button widget.button
local FilePicker = Widget:extend()

---Operation modes for the file picker.
---@type table<string,integer>
FilePicker.mode = {
  ---Opens file browser the selected file does not has to exist.
  FILE = 1,
  ---Opens file browser the selected file has to exist.
  FILE_EXISTS = 2,
  ---Opens directory browser the selected directory does not has to exist.
  DIRECTORY = 4,
  ---Opens directory browser the selected directory has to exist.
  DIRECTORY_EXISTS = 8
}

---@param text string
local function suggest_directory(text)
  text = common.home_expand(text)
  return common.home_encode_list(common.dir_path_suggest(text))
end

---@param path string
local function check_directory_path(path)
  local abs_path = system.absolute_path(path)
  local info = abs_path and system.get_file_info(abs_path)
  if not info or info.type ~= 'dir' then return nil end
  return abs_path
end

---@param str string
---@param find string
---@param replace string
local function str_replace(str, find, replace)
  local start, ending = str:find(find, 1, true)
  if start == 1 then
    return replace .. str:sub(ending + 1)
  else
    return str:sub(1, start - 1) .. replace .. str:sub(ending + 1)
  end
end

---@alias widget.filepicker.modes
---| `FilePicker.mode.FILE`
---| `FilePicker.mode.FILE_EXISTS`
---| `FilePicker.mode.DIRECTORY`
---| `FilePicker.mode.DIRECTORY_EXISTS`

---Constructor
---@param parent widget
---@param path? string
function FilePicker:new(parent, path)
  FilePicker.super.new(self, parent)

  local this = self

  self.type_name = "widget.filepicker"

  self.filters = {}
  self.border.width = 0
  self.pick_mode = FilePicker.mode.FILE

  self.file = Label(self, "")
  self.file.clickable = true
  self.file:set_border_width(1)
  function self.file:on_click(button)
    if button == "left" then
      this:show_picker()
    end
  end
  function self.file:on_mouse_enter(...)
    Label.super.on_mouse_enter(self, ...)
    self.border.color = style.caret
  end
  function self.file:on_mouse_leave(...)
    Label.super.on_mouse_leave(self, ...)
    self.border.color = style.text
  end

  self.button = Button(self, "")
  self.button:set_icon("D")
  self.button:set_tooltip("open file browser")
  function self.button:on_click(button)
    if button == "left" then
      this:show_picker()
    end
  end

  local label_width = self.file:get_width()
  if label_width <= 10 then
    label_width = 200 + (self.file.border.width * 2)
    self.file:set_size(200, self.button:get_height() - self.button.border.width * 2)
  end

  self:set_size(
    label_width + self.button:get_width(),
    math.max(self.file:get_height(), self.button:get_height())
  )

  self:set_path(path)
end

---Set the filepicker size
---@param width? number
---@param height? number
function FilePicker:set_size(width, height)
  FilePicker.super.set_size(self, width, height)

  self.file:set_position(0, 0)
  self.file:set_size(
    self:get_width() - self.button:get_width(),
    self.button:get_height()
  )

  self.button:set_position(self.file:get_right(), 0)

  self.size.y = math.max(
    self.file:get_height(),
    self.button:get_height()
    -- something is off on calculation since adding border width should not
    -- be needed to display whole rendered control at all...
  ) + self.button.border.width
end

---Add a lua pattern to the filters list
---@param pattern string
function FilePicker:add_filter(pattern)
  table.insert(self.filters, pattern)
end

---Clear the filters list
function FilePicker:clear_filters()
  self.filters = {}
end

---Set the operation mode for the file picker.
---@param mode widget.filepicker.modes | string | integer
function FilePicker:set_mode(mode)
  if type(mode) == "string" then
    ---@type integer
    local intmode = FilePicker.mode[mode:upper()]
    self.pick_mode = intmode
  else
    self.pick_mode = mode
  end
end

---Set the full path including directory and filename.
---@param path? string
function FilePicker:set_path(path)
  if path then
    self.path = path or ""
    if common.path_belongs_to(path, core.project_dir) then
      self.file.label = path ~= "" and
        common.relative_path(core.project_dir, path)
        or
        ""
    else
      self.file.label = path
    end
  else
    self.path = ""
    self.file.label = ""
  end
end

---Get the full path including directory and filename.
---@return string | nil
function FilePicker:get_path()
  if self.path ~= "" then
    return self.path
  end
  return nil
end

---Get the full path relative to current project dir or absolute if it doesn't
---belongs to the current project directory.
---@return string
function FilePicker:get_relative_path()
  if
    self.path ~= ""
    and
    common.path_belongs_to(self.path, core.project_dir)
  then
    return common.relative_path(core.project_dir, self.path)
  end
  return self.path or ""
end

---Set the filename part only.
---@param name string
function FilePicker:set_filename(name)
  local dir_part = common.dirname(self.path)
  if dir_part then
    self:set_path(dir_part .. "/" .. name)
  else
    self:set_path(name)
  end
end

---Get the filename part only.
---@return string | nil
function FilePicker:get_filename()
  local dir_part = common.dirname(self.path)
  if dir_part then
    local filename = str_replace(self.path, dir_part .. "/", "")
    return filename
  elseif self.path ~= "" then
    return self.path
  end
  return nil
end

---Set the directory part only.
---@param dir string
function FilePicker:set_directory(dir)
  local filename = self:get_filename()
  if filename then
    self:set_path(dir:gsub("[\\/]$", "") .. "/" .. filename)
  else
    self:set_path(dir:gsub("[\\/]$", ""))
  end
end

---Get the directory part only.
---@return string | nil
function FilePicker:get_directory()
  if self.path ~= "" then
    local dir_part = common.dirname(self.path)
    if dir_part then return dir_part end
  end
  return nil
end

---Filter a list of directories by applying currently set filters.
---@param self widget.filepicker
---@param list table<integer, string>
---@return table<integer,string>
local function filter(self, list)
  if #self.filters > 0 then
    local new_list = {}
    for _, value in ipairs(list) do
      if common.match_pattern(value, self.filters) then
        table.insert(new_list, value)
      elseif
        self.pick_mode == FilePicker.mode.FILE
        or
        self.pick_mode == FilePicker.mode.FILE_EXISTS
      then
        local path = common.home_expand(value)
        local abs_path = check_directory_path(path)
        if abs_path then
          table.insert(new_list, value)
        end
      end
    end
    return new_list
  end
  return list
end

---@param self widget.filepicker
local function show_file_picker(self)
  core.command_view:enter("Choose File", {
    text = self:get_relative_path(),
    submit = function(text)
      ---@type string
      local filename = text
      local dirname = common.dirname(common.home_expand(text))
      if dirname then
        filename = common.home_expand(text)
        filename = system.absolute_path(dirname)
          .. "/"
          .. str_replace(filename, dirname .. "/", "")
      elseif filename ~= "" then
        filename = core.project_dir .. "/" .. filename
      end
      self:set_path(filename)
      self:on_change(filename ~= "" and filename or nil)
    end,
    suggest = function (text)
      return filter(
        self,
        common.home_encode_list(common.path_suggest(common.home_expand(text)))
      )
    end,
    validate = function(text)
      if #self.filters > 0 and text ~= "" and not common.match_pattern(text, self.filters) then
        core.error(
          "File does not match the filters: %s",
          table.concat(self.filters, ", ")
        )
        return false
      end
      local filename = common.home_expand(text)
      local path_stat, err = system.get_file_info(filename)
      if path_stat and path_stat.type == 'dir' then
        core.error("Cannot open %s, is a folder", text)
        return false
      end
      if self.pick_mode == FilePicker.mode.FILE_EXISTS then
        if not path_stat then
          core.error("Cannot open file %s: %s", text, err)
          return false
        end
      else
        local dirname = common.dirname(filename)
        local dir_stat = dirname and system.get_file_info(dirname)
        if dirname and not dir_stat then
          core.error("Directory does not exists: %s", dirname)
          return false
        end
      end
      return true
    end,
  })
end

---@param self widget.filepicker
local function show_dir_picker(self)
  core.command_view:enter("Choose Directory", {
    text = self:get_relative_path(),
    submit = function(text)
      local path = common.home_expand(text)
      local abs_path = check_directory_path(path)
      self:set_path(abs_path or text)
      self:on_change(abs_path or (text ~= "" and text or nil))
    end,
    suggest = function(text)
      return filter(self, suggest_directory(text))
    end,
    validate = function(text)
      if #self.filters > 0 and text ~= "" and not common.match_pattern(text, self.filters) then
        core.error(
          "Directory does not match the filters: %s",
          table.concat(self.filters, ", ")
        )
        return false
      end
      if self.pick_mode == FilePicker.mode.DIRECTORY_EXISTS then
        local path = common.home_expand(text)
        local abs_path = check_directory_path(path)
        if not abs_path then
          core.error("Cannot open directory %q", path)
          return false
        end
      end
      return true
    end
  })
end

---Show the command view file or directory browser depending on the
---current file picker mode.
function FilePicker:show_picker()
  if
    self.pick_mode == FilePicker.mode.FILE
    or
    self.pick_mode == FilePicker.mode.FILE_EXISTS
  then
    show_file_picker(self)
  else
    show_dir_picker(self)
  end
end

function FilePicker:update()
  if not FilePicker.super.update(self) then return false end

  if self:get_width() ~= (self.file:get_width() + self.button:get_width()) then
    self:set_size(
      self.file:get_width() + self.button:get_width(),
      self.button:get_height()
    )
  end

  return true
end


return FilePicker
