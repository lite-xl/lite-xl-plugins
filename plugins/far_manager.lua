-- mod-version:3

local core = require "core"
local style = require "core.style"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local View = require "core.view"
local system = require "system"

local FileManagerView = View:extend()

function FileManagerView:new()
  FileManagerView.super.new(self)
  self.left_path = core.project_dir or "."
  self.right_path = self.left_path
  self.left_files = self:list_dir(self.left_path)
  self.right_files = self:list_dir(self.right_path)
  self.active_panel = "left"
  self.left_cursor = 1
  self.right_cursor = 1
end

function FileManagerView:list_dir(path)
  local files = system.list_dir(path) or {}
  table.sort(files)
  return files
end

function FileManagerView:draw()
  self:draw_background(style.background)

  local w = self.size.x / 2
  local h = self.size.y

  -- draw left panel
  self:draw_panel(0, 0, w, h, self.left_path, self.left_files, self.active_panel == "left", self.left_cursor)

  -- draw right panel
  self:draw_panel(w, 0, w, h, self.right_path, self.right_files, self.active_panel == "right", self.right_cursor)
end

function FileManagerView:draw_panel(x, y, w, h, path, files, active, cursor)
  -- draw border
  local color = active and style.accent or style.dim
  renderer.draw_rect(x, y, w, h, color)

  -- draw path
  renderer.draw_text(style.font, path, x + style.padding.x, y + style.padding.y, style.text)

  local yy = y + style.padding.y * 2 + style.font:get_height()
  for i, file in ipairs(files) do
    local color = (i == cursor) and style.accent or style.text
    renderer.draw_text(style.font, file, x + style.padding.x, yy, color)
    yy = yy + style.font:get_height()
  end
end

function FileManagerView:on_mouse_pressed(button, x, y, clicks)
  local w = self.size.x / 2
  if x < w then
    self.active_panel = "left"
  else
    self.active_panel = "right"
  end
  -- calculate cursor
  local panel_y = y - style.padding.y * 2 - style.font:get_height()
  local line_h = style.font:get_height()
  local cursor = math.floor(panel_y / line_h) + 1
  if self.active_panel == "left" then
    self.left_cursor = math.max(1, math.min(#self.left_files, cursor))
  else
    self.right_cursor = math.max(1, math.min(#self.right_files, cursor))
  end
end

function FileManagerView:on_key_pressed(key, mod)
  if key == "tab" then
    self.active_panel = self.active_panel == "left" and "right" or "left"
  elseif key == "up" then
    self:move_cursor(-1)
  elseif key == "down" then
    self:move_cursor(1)
  elseif key == "return" then
    self:open_selected()
  elseif key == "backspace" then
    self:go_up()
  end
end

function FileManagerView:move_cursor(dir)
  if self.active_panel == "left" then
    self.left_cursor = math.max(1, math.min(#self.left_files, self.left_cursor + dir))
  else
    self.right_cursor = math.max(1, math.min(#self.right_files, self.right_cursor + dir))
  end
end

function FileManagerView:open_selected()
  local path, file
  if self.active_panel == "left" then
    path = self.left_path
    file = self.left_files[self.left_cursor]
  else
    path = self.right_path
    file = self.right_files[self.right_cursor]
  end
  if file then
    local full_path = path .. PATHSEP .. file
    local info = system.get_file_info(full_path)
    if info and info.type == "dir" then
      if self.active_panel == "left" then
        self.left_path = full_path
        self.left_files = self:list_dir(full_path)
        self.left_cursor = 1
      else
        self.right_path = full_path
        self.right_files = self:list_dir(full_path)
        self.right_cursor = 1
      end
    else
      core.open_doc(full_path)
    end
  end
end

function FileManagerView:go_up()
  local path
  if self.active_panel == "left" then
    path = self.left_path
  else
    path = self.right_path
  end
  local parent = system.get_file_info(path).parent or "."
  if self.active_panel == "left" then
    self.left_path = parent
    self.left_files = self:list_dir(parent)
    self.left_cursor = 1
  else
    self.right_path = parent
    self.right_files = self:list_dir(parent)
    self.right_cursor = 1
  end
end

command.add(nil, {
  ["far-manager:open"] = function()
    core.root_view:get_active_node():add_view(FileManagerView())
  end,
})