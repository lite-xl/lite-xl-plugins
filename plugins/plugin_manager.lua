-- mod-version:3 --lite-xl 2.1

-- Plugin manager for Lite XL.
-- Determines dependencies by looking at the `require` statements in the root file of your plugin (either `plugin_name.lua`, or `plugin_name/init.lua`).
-- Currently there is no versioning.

local core = require "core"
local style = require "core.style"
local common = require "core.common"
local config = require "core.config"
local command = require "core.command"
local curl = require "plugins.support_curl"
local json = require "plugins.support_json"
local base64 = require "plugins.support_base64"

local PluginManager = common.merge({
  -- Path to a JSON file that holds the full listing of all remote plugins.
  cache = USERDIR  .. PATHSEP .. "plugin_manager.json",
  -- Path to the folder that holds user-specified plugins.
  user_plugin_directory = USERDIR .. PATHSEP .. "plugins",
  -- Path to the directory that holds lite-xl core plugins.
  system_plugin_directory = DATADIR .. PATHSEP .. "plugins",
  -- How long we go by default before transparently refreshing the listing.
  retrieval_tolerance = 10*60,
  -- Where we get the plugin listing.
  repositories = { { type = "github", name = "lite-xl/lite-xl-plugins", branch = "master" } },
  -- The branch we get it on.
  branch = "master",
  
  remote_plugins = nil,
  local_plugins = nil,
  requires_restart = false,
  last_retrieval = nil
}, config.plugins.plugin_manager)


local function parse_plugin_listing(list)
  local plugins = {}
  for i,v in ipairs(list) do
    local path = v["path"]:gsub("%.lua", "")
    local old_plugin = PluginManager.plugins and PluginManager.plugins[path]
    v.retrieved = old_plugin and old_plugin["sha"] == v["sha"] and old_plugin["retrieved"] or os.time()
    v.remote = true
    v.version = nil
    v.package = path
    v.type = "user"
    v.composite = v["type"] == "tree"
    v.url = v["url"]
    v.data = nil
    plugins[path] = v
  end
  return plugins
end


local function convert_to_path(type, plugin_name, file)
  return PluginManager[type .. "_plugin_directory"] .. PATHSEP .. plugin_name:gsub("^plugin%.", ""):gsub("%.", PATHSEP) .. (file and ".lua" or "")
end


local function convert_to_package(path)
  return path:gsub(PluginManager.user_plugin_directory, ""):gsub(PluginManager.system_plugin_directory, ""):gsub("%.lua", ""):gsub(PATHSEP, ".")
end


local function copy_github_remote_tree_to_disk(url, path, parent_plugin, done)
  local got_body = function(data)
    if data.tree then
      if not system.get_file_info(path) then common.mkdirp(path) end
      local count = 0
      local success = function() 
        count = count + 1
        if count == #data.tree then done() end
      end
      for i, v in data.tree do
        copy_github_remote_tree_to_disk(v.url, path .. PATHSEP .. v.path, success)
      end
    else
      io.open(path, "wb"):write(base64.decode(data.content))
      done()
    end
  end
  if parent_plugin and parent_plugin.url == url and parent_plugin.details.data then
    got_body(parent_plugin.details.data)
  else
    curl.request({ url = url }, function(body) local data = json.decode(body) got_body(data) end)
  end
end


local function compute_properties(content)
  local s, _, package = 0
  local dependencies = {}
  while true do
    s, _, package = content:find("plugins%.([%w_%.]+)", s + 1)
    if not package then break end
    table.insert(dependencies, { package = package, version = nil })
  end
  return { dependencies = dependencies }
end


function PluginManager:get_details(plugin_metadata, done)
  if plugin_metadata.details then
    done(plugin_metadata.details)
  elseif plugin_metadata.remote then
     curl.request({ url = plugin_metadata.url }, function(body)
      local data = json.decode(body)
      if data.content then
        local content = base64.decode(data.content)
        plugin_metadata.details = common.merge({ data = data, content = content }, compute_properties(content))
        done(plugin_metadata.details)
      elseif data.tree then
        local target
        for i, v in ipairs(data.tree) do if v.path == "init.lua" then target = v break end end
        if target then
          curl.request({ url = target.url }, function(body)
            local data = json.decode(body)
            local content = base64.decode(data.content)
            plugin_metadata.details = common.merge({ data = data, content = content }, compute_properties(content))
            done(plugin_metadata.details)
          end)
        else  
          error("Can't find plugin's init.lua.");
        end
      else
        error("Unknown type of plugin.")
      end
    end)
  else
    local path = convert_to_path(plugin_metadata.type, plugin_metadata.package)
    path = plugin_metadata.composite and path .. ".lua" or path .. "/init.lua"
    local content = io.open(path, "rb"):read("*all")
    plugin_metadata.details = common.merge({ content = content }, compute_properties(content))
    done(plugin_metadata.details)
  end
end


function PluginManager:refresh_local_plugins()
  self.local_plugins = {}
  for type, dir in pairs({ user = self.user_plugin_directory, system = self.system_plugin_directory }) do
    for i, v in ipairs(system.list_dir(dir)) do
      local package = convert_to_package(v)
      self.local_plugins[package] = {
        retrieved = system.get_file_info(dir .. PATHSEP .. v).modified,
        dependencies = {},
        version = nil,
        remote = false,
        type = type,
        package = package
      }
    end
  end
end


function PluginManager:refresh(done, log)
  local repository = self.repositories[1]
  self:refresh_local_plugins()
  if log then log("Retrieving plugin listing from repository " .. repository.name .. ".") end
  curl.request({ url = "https://api.github.com/repos/" .. repository.name .. "/git/trees" .. "/" .. repository.branch }, function(body) 
    local master_listing = json.decode(body)
    for i,folder in ipairs(master_listing["tree"]) do
      if folder["path"] == "plugins" then
        curl.request({ url = folder["url"] }, function(body)
          self.remote_plugins = parse_plugin_listing(json.decode(body)["tree"])
          io.open(self.cache, "wb"):write(json.encode(self.remote_plugins))
          if done then done(self.remote_plugins) end
        end)
      end
    end
  end)
end


local info = system.get_file_info(PluginManager.cache)
PluginManager.last_retrieval = info and info.modified
if info then
  local success, list = core.try(function() return json.decode(io.open(PluginManager.cache, "rb"):read("*a")) end)
  PluginManager.remote_plugins = success and list
  PluginManager:refresh_local_plugins()
else
  PluginManager:refresh()
end


function PluginManager:get_list(done)
  if self.last_retrieval == nil or self.last_retrieval + self.retrieval_tolerance < os.time() then
    self:refresh(done)
  else
    done(self.remote_plugins)
  end
end


function PluginManager:install(remote_plugin_metadata, done, log)
  self:get_details(remote_plugin_metadata, function(details)
    if log then log("Got details of " .. remote_plugin_metadata.package .. ".") end
    local copy_plugin = function()
      copy_github_remote_tree_to_disk(remote_plugin_metadata.url, convert_to_path(remote_plugin_metadata.type, remote_plugin_metadata.package, remote_plugin_metadata.path:find("%.lua")), remote_plugin_metadata, function()
        self.requires_restart = true
        local local_plugin = {
          retrieved = os.time(),
          dependencies = {},
          version = nil,
          remote = false,
          type = "user",
          package = remote_plugin_metadata.package
        }
        self.local_plugins[remote_plugin_metadata.package] = local_plugin
        if done then done(local_plugin) end
      end)
    end
  
    local fulfilled_dependencies = 0    
    for i,v in ipairs(details.dependencies) do
      if not self.local_plugins[v.package] then
        if log then log("Can't find " .. v.package .. " locally. Attempting to fetch remotely.") end
        self:install_name(v.package, v.version, function() 
          fulfilled_dependencies = fulfilled_dependencies + 1 
          if fulfilled_dependencies == #details.dependencies then copy_plugin() end
        end, log)
      else
        fulfilled_dependencies = fulfilled_dependencies + 1
      end
    end
    if fulfilled_dependencies == #details.dependencies then copy_plugin() end
  end)
end


function PluginManager:remove(local_plugin_metadata)
  local path = convert_to_path(local_plugin_metadata.type, local_plugin_metadata.package, not local_plugin_metadata.composite)
  local success, err = common.rm(path, true)
  if not success then error("error removing " .. path .. ": " .. err) else self.requires_restart = true end
  self.remote_plugins[local_plugin_metadata.package] = nil
  return success
end


function PluginManager:get_remote_plugin(package, version, done)
  self:get_list(function(plugins) 
    if plugins[package] then 
      done(plugins[package]) 
    else 
      error("Can't find remote plugin " .. package .. ".") 
    end
  end)
end


function PluginManager:get_local_plugin(package, version, done)
  if self.local_plugins[package] then done(self.local_plugins[package]) else error("Can't find local plugin " .. package .. ".") end
end


function PluginManager:remove_name(plugin_name, version) self:get_local_plugin(plugin_name, version, function(plugin) self:remove(plugin) end) end
function PluginManager:install_name(plugin_name, version, done, log) self:get_remote_plugin(plugin_name, version, function(plugin) self:install(plugin, done, log) end) end


local function get_suggestions(plugin_list, text)
  if plugin_list then
    local items = {}
    for name, plugin in pairs(plugin_list) do
      if plugin.type == "user" then table.insert(items, name) end
    end
    return common.fuzzy_match(items, text)
  end
end


command.add(nil, {
  ["plugin-manager:install"] = function() 
    core.command_view:enter("Enter plugin name", 
      function(name)  
        core.log("Attempting to install plugin " .. name .. "...")
        PluginManager:install_name(name, nil, function(local_plugin_medata) 
          core.log("Successfully installed plugin " .. name .. ".")
        end, core.log) 
      end, 
      function(text) return get_suggestions(PluginManager.remote_plugins, text) end
    )
  end,
  ["plugin-manager:remove"] = function() 
    core.command_view:enter("Enter plugin name",
      function(name)  
        core.log("Attempting to remove plugin " .. name .. "...")
        PluginManager:remove_name(name) 
        core.log("Successfully removed plugin " .. name .. ".")
      end, 
      function(text)  return get_suggestions(PluginManager.local_plugins, text) end
    )
  end,
  ["plugin-manager:refresh"] = function() PluginManager:refresh(function() core.log("Successfully refreshed plugin listing.") end, core.log) end
})


return PluginManager
