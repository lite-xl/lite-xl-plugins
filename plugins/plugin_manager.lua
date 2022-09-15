-- mod-version:3 --lite-xl 2.1

local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local command = require "core.command"
local json = require "plugins.support_json"
local View = require "core.view"
local keymap = require "core.keymap"
local ContextMenu = require "core.contextmenu"
local RootView = require "core.rootview"


local PluginManager = {
  last_refresh = nil,
  requires_restart = false
}
config.plugins.plugin_manager = common.merge({
  lpm_binary_name = "lpm." .. ARCH .. (PLATFORM == "Windows" and ".exe" or ""),
  lpm_binary_path = nil,
  -- Restarts the plugin manager on changes.
  restart_on_change = true,
  -- Path to a local copy of all repositories.
  cachdir = USERDIR  .. PATHSEP .. "lpm",
  -- Path to the folder that holds user-specified plugins.
  userdir = USERDIR,
  -- Path to ssl certificate directory.
  ssl_certs = nil
}, config.plugins.plugin_manager)

if not config.plugins.plugin_manager.lpm_binary_path then
  local paths = { 
    DATADIR .. PATHSEP .. "plugins" .. PATHSEP .. "plugin_manager" .. PATHSEP .. config.plugins.plugin_manager.lpm_binary_name,
    DATADIR .. PATHSEP .. "plugins" .. PATHSEP .. "plugin_manager" .. PATHSEP .. config.plugins.plugin_manager.lpm_binary_name,
    USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "plugin_manager" .. PATHSEP .. "lpm",
    USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "plugin_manager" .. PATHSEP .. "lpm",
  }
  local path, s = os.getenv("PATH"), 1
  while true do
    local _, e = path:find(":", s)
    table.insert(paths, path:sub(s, e and (e-1) or #path) .. PATHSEP .. "lpm")
    if not e then break end
    s = e + 1
  end
  for i, path in ipairs(paths) do
    if system.get_file_info(path) then 
      config.plugins.plugin_manager.lpm_binary_path = path 
      break 
    end
  end
end
if not config.plugins.plugin_manager.lpm_binary_path then error("can't find lpm binary, please supply one with config.plugins.plugin_manager.lpm_binary_path") end

local Promise = { }
function Promise:__index(idx) return rawget(self, idx) or Promise[idx] end
function Promise.new(result) return setmetatable({ result = result, success = nil, _done = { }, _fail = { } }, Promise) end
function Promise:done(done) if self.success == true then done(self.result) else table.insert(self._done, done) end return self end
function Promise:fail(fail) if self.success == false then fail(self.result) else table.insert(self._fail, fail) end return self end
function Promise:resolve(result) self.result = result self.success = true for i,v in ipairs(self._done) do v(result) end return self end
function Promise:reject(result) self.result = result self.success = false for i,v in ipairs(self._fail) do v(result) end return self end
function Promise:forward(promise) self:done(function(data) promise:resolve(data) end) self:fail(function(data) promise:reject(data) end) return self end

local running_processes = {}

local function run(cmd)
  local t = { config.plugins.plugin_manager.lpm, table.unpack(cmd), "--json", "--mod-version", MOD_VERSION }
  if config.plugins.plugin_manager.ssl_certs then table.insert(t, "--ssl_certs") table.insert(t, config.plugins.plugin_manager.ssl_certs) end 
  table.insert(cmd, 1, config.plugins.plugin_manager.lpm_binary_path)
  table.insert(cmd, "--json")
  table.insert(cmd, "--mod-version=" .. MOD_VERSION)
  table.insert(cmd, "--quiet")
  table.insert(cmd, "--userdir=" .. USERDIR)
  -- print(table.unpack(cmd))
  local proc = process.start(cmd)
  local promise = Promise.new()
  table.insert(running_processes, { proc, promise, "" })
  if #running_processes == 1 then
    core.add_thread(function()
      while #running_processes > 0 do 
        local still_running_processes = {}
        local has_chunk = false
        local i = 1
        while i < #running_processes + 1 do
          local v = running_processes[i]
          local still_running = true
          while true do
            local chunk = v[1]:read_stdout(2048)
            if chunk and #chunk == 0 then break end
            if chunk ~= nil then 
              v[3] = v[3] .. chunk 
              has_chunk = true
            else
              still_running = false
              if v[1]:returncode() == 0 then
                v[2]:resolve(v[3])
              else
                local err = v[1]:read_stderr(2048)
                core.error("error running lpm: " .. err)
                v[2]:reject(v[3])
              end
              break
            end
          end
          if still_running then
            table.insert(still_running_processes, v)
          end
          i = i + 1
        end
        running_processes = still_running_processes
        coroutine.yield(has_chunk and 0.001 or 0.1)
      end
    end)
  end
  return promise
end


function PluginManager:refresh()
  return run({ "plugin", "list" }):done(function(plugins)
    self.plugins = json.decode(plugins)["plugins"]
    table.sort(self.plugins, function(a,b) return a.name < b.name end)
    self.valid_plugins = {}
    for i, plugin in ipairs(self.plugins) do
      if plugin.status ~= "incompatible" then
        table.insert(self.valid_plugins, plugin)
      end
    end
    self.last_refresh = os.time()
  end)
end


function PluginManager:install(plugin)
  local promise = Promise.new()
  run({ "plugin", "install", plugin.name .. (plugin.version and (":" .. plugin.version) or "") }):done(function(result)
    if config.plugins.plugin_manager.restart_on_change then
      command.perform("core:restart")
    else
      self:refresh():forward(promise)
    end
  end)
  return promise
end


function PluginManager:uninstall(plugin)
  local promise = Promise.new()
  run({ "plugin", "uninstall", plugin.name }):done(function(result)
    if config.plugins.plugin_manager.restart_on_change then
      command.perform("core:restart")
    else
      self:refresh():forward(promise)
    end
  end)
  return promise
end


local function get_suggestions(text)
  local items = {}
  if not PluginManager.plugins then return end
  for i, plugin in ipairs(PluginManager.plugins) do
    if not plugin.mod_version or tostring(plugin.mod_version) == tostring(MOD_VERSION) then
      table.insert(items, plugin.name .. ":" .. plugin.version)
    end
  end
  return common.fuzzy_match(items, text)
end



local PluginView = View:extend()


local function join(joiner, t)
  local s = ""
  for i,v in ipairs(t) do if i > 1 then s = s .. joiner end s = s .. v end
  return s
end


local plugin_view = nil
PluginView.menu = ContextMenu()

PluginView.menu:register(nil, {
  { text = "Install", command = "plugin-manager:install-hovered" },
  { text = "Uninstall", command = "plugin-manager:uninstall-hovered" }
})

function PluginView:new()
  PluginView.super.new(self)
  self.scrollable = true
  self.show_incompatible_plugins = false
  self.plugin_table_columns = { "Name", "Version", "Modversion", "Status", "Tags", "Description" }
  self:refresh()
  self.hovered_plugin = nil
  self.hovered_plugin_idx = nil
  self.selected_plugin = nil
  self.selected_plugin_idx = nil
  plugin_view = self
end

local function get_plugin_text(plugin)
  return plugin.name, plugin.version, plugin.mod_version, plugin.status, join(", ", plugin.tags), plugin.description-- (plugin.description or ""):gsub("%[[^]+%]%([^)]+%)", "")
end


function PluginView:get_name()
  return "Plugin Manager"
end


local root_view_update = RootView.update
function RootView:update(...)
  root_view_update(self, ...)
  PluginView.menu:update()
end


local root_view_draw = RootView.draw
function RootView:draw(...)
  root_view_draw(self, ...)
  PluginView.menu:draw()
end


local root_view_on_mouse_moved = RootView.on_mouse_moved
function RootView:on_mouse_moved(...)
  if PluginView.menu:on_mouse_moved(...) then return end
  return root_view_on_mouse_moved(self, ...)
end


local on_view_mouse_pressed = RootView.on_view_mouse_pressed
function RootView.on_view_mouse_pressed(button, x, y, clicks)
  local handled = PluginView.menu:on_mouse_pressed(button, x, y, clicks)
  return handled or on_view_mouse_pressed(button, x, y, clicks)
end


function PluginView:on_mouse_moved(x, y, dx, dy)
  PluginView.super.on_mouse_moved(self, x, y, dx, dy)
  local th = style.font:get_height()
  local lh = th + style.padding.y
  local offset = math.floor((y - self.position.y + self.scroll.y) / lh)
  self.hovered_plugin = offset > 0 and self:get_plugins()[offset]
  self.hovered_plugin_idx = offset > 0 and offset
end


function PluginView:refresh()
  self.widths = {}
  for i,v in ipairs(self.plugin_table_columns) do
    table.insert(self.widths, style.font:get_width(v))
  end
  for i, plugin in ipairs(self:get_plugins()) do
    local t = { get_plugin_text(plugin) }
    for j = 1, #self.widths do  
      self.widths[j] = math.max(style.font:get_width(t[j] or ""), self.widths[j])
    end
  end
end


function PluginView:get_plugins()
  if self.show_incompatible_plugins then return PluginManager.plugins end
  return PluginManager.valid_plugins
end


function PluginView:get_scrollable_size()
  local th = style.font:get_height() + style.padding.y
  return th * #self:get_plugins()
end


local function mul(color1, color2)
  return { color1[1] * color2[1] / 255, color1[2] * color2[2] / 255, color1[3] * color2[3] / 255, color1[4] * color2[4] / 255 }
end


function PluginView:draw()
  self:draw_background(style.background)
  
  local th = style.font:get_height()
  local lh = th + style.padding.y

  local ox, oy = self:get_content_offset()
  core.push_clip_rect(self.position.x, self.position.y, self.size.x, self.size.y)
  local x, y = ox + style.padding.x, oy
  for i, v in ipairs(self.plugin_table_columns) do
    common.draw_text(style.font, style.accent, v, "left", x, y, self.widths[i], lh)
    x = x + self.widths[i] + style.padding.x
  end
  oy = oy + lh
  for i, plugin in ipairs(self:get_plugins()) do
    local x, y = ox, oy
    if y + lh >= self.position.y and y <= self.position.y + self.size.y then
      if plugin == self.selected_plugin then 
        renderer.draw_rect(x, y, self.size.x, lh, style.dim)
      elseif plugin == self.hovered_plugin then
        renderer.draw_rect(x, y, self.size.x, lh, style.line_highlight)
      end
      x = x + style.padding.x
      for j, v in ipairs({ get_plugin_text(plugin) }) do
        local color = plugin.status == "installed" and style.good or style.text
        if self.loading then color = mul(color, style.dim) end
        common.draw_text(style.font, color, v, "left", x, y, self.widths[j], lh)
        x = x + self.widths[j] + style.padding.x
      end
    end
    oy = oy + lh
  end
  core.pop_clip_rect()
  PluginView.super.draw_scrollbar(self)
end

function PluginView:install(plugin)
  self.loading = true
  PluginManager:install(plugin):done(function()
    self.loading = false
    self.selected_plugin, plugin_view.selected_plugin_idx = nil, nil
  end)
end

function PluginView:uninstall(plugin)
  self.loading = true
  PluginManager:uninstall(plugin):done(function()
    self.loading = false
    self.selected_plugin, plugin_view.selected_plugin_idx = nil, nil
  end)
end

PluginManager.view = PluginView
PluginManager:refresh():done(function()
  command.perform("plugin-manager:show")
end)

command.add(PluginView, {
  ["plugin-manager:select"] = function(x, y) 
    plugin_view.selected_plugin, plugin_view.selected_plugin_idx = plugin_view.hovered_plugin, plugin_view.hovered_plugin_idx 
  end,
})
command.add(function()
  return core.active_view and core.active_view:is(PluginView) and plugin_view.selected_plugin and plugin_view.selected_plugin.status == "available"
end, {
  ["plugin-manager:install-selected"] = function() plugin_view:install(plugin_view.selected_plugin) end
})
command.add(function()
  return core.active_view and core.active_view:is(PluginView) and plugin_view.hovered_plugin and plugin_view.hovered_plugin.status == "available"
end, {
  ["plugin-manager:install-hovered"] = function() plugin_view:install(plugin_view.hovered_plugin) end
})
command.add(function()
  return core.active_view and core.active_view:is(PluginView) and plugin_view.selected_plugin and plugin_view.selected_plugin.status == "installed"
end, {
  ["plugin-manager:uninstall-selected"] = function() plugin_view:uninstall(plugin_view.selected_plugin) end
})
command.add(function()
  return core.active_view and core.active_view:is(PluginView) and plugin_view.hovered_plugin and plugin_view.hovered_plugin.status == "installed"
end, {
  ["plugin-manager:uninstall-hovered"] = function() plugin_view:uninstall(plugin_view.hovered_plugin) end
})

command.add(nil, {
  ["plugin-manager:show"] = function()
    local node = core.root_view:get_active_node_default()
    node:add_view(PluginView())
  end,
  ["plugin-manager:install"] = function() 
    core.command_view:enter("Enter plugin name", 
      function(name)  
        core.log("Attempting to install plugin " .. name .. "...")
        PluginManager:install(name, nil):done(function()
          core.log("Successfully installed plugin " .. name .. ".")
        end) 
      end, 
      function(text) return get_suggestions(text) end
    )
  end,
  ["plugin-manager:remove"] = function() 
    core.command_view:enter("Enter plugin name",
      function(name)  
        core.log("Attempting to remove plugin " .. name .. "...")
        PluginManager:uninstall(name):done(function()
          core.log("Successfully removed plugin " .. name .. ".")
        end)
      end, 
      function(text)  return get_suggestions(PluginManager.local_plugins, text) end
    )
  end,
  ["plugin-manager:refresh"] = function() PluginManager:refresh():done(function() core.log("Successfully refreshed plugin listing.") end) end,
})



keymap.add {
  ["up"]          = "plugin-manager:select-prev",
  ["down"]        = "plugin-manager:select-next",
  ["lclick"]      = "plugin-manager:select",
  ["2lclick"]     = { "plugin-manager:install-selected", "plugin-manager:uninstall-selected" }
}

return PluginManager
