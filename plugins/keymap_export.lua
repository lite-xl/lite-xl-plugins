-- mod-version:3

-- Author:      Takase (takase1121)
-- Description: Exports the keymap into a JSON file.
-- License:     MIT

-- This file contains source code modified from https://github.com/rxi/json.lua
-- The source code is under MIT and the license is at the end of this file.

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"

-- not configurable via config for obvious reasons
local QUIT_AFTER_EXPORT = false

config.plugins.keymap_export = common.merge({
  export_type = "reverse_map",
  destination = "doc",
  allow_env = true,
  autostart = false,
  config_spec = {
    name = "Keymap export",
    {
      label = "Export type",
      description = "Which part of the keymap to export.",
      path = "export_type",
      type = "selection",
      default = "reverse_map",
      values = {
        { "Map", "map" },
        { "Reverse map", "reverse_map" }
      }
    },
    {
      label = "Export destination",
      description = "The destination. Set to 'doc' or a filename.",
      path = "destination",
      type = "string",
      default = "doc"
    },
    {
      label = "Allow environment variables",
      description = "Allow using environment variables to modify config.",
      path = "allow_env",
      type = "toggle",
      default = true
    },
    {
      label = "Autostart",
      description = "Automatically export on Lite XL startup.",
      path = "autostart",
      type = "toggle",
      default = false
    }
  }
}, config.plugins.keymap_export)

local conf = config.plugins.keymap_export

-----------------------------------------------------------
-- START OF json.lua
-----------------------------------------------------------

local encode

local escape_char_map = {
  [ "\\" ] = "\\",
  [ "\"" ] = "\"",
  [ "\b" ] = "b",
  [ "\f" ] = "f",
  [ "\n" ] = "n",
  [ "\r" ] = "r",
  [ "\t" ] = "t",
}

local escape_char_map_inv = { [ "/" ] = "/" }
for k, v in pairs(escape_char_map) do
  escape_char_map_inv[v] = k
end


local function escape_char(c)
  return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end


local function encode_nil(val)
  return "null"
end


local function encode_table(val, stack)
  local res = {}
  stack = stack or {}

  -- Circular reference?
  if stack[val] then error("circular reference") end

  stack[val] = true

  if rawget(val, 1) ~= nil or next(val) == nil then
    -- Treat as array -- check keys are valid and it is not sparse
    local n = 0
    for k in pairs(val) do
      if type(k) ~= "number" then
        error("invalid table: mixed or invalid key types")
      end
      n = n + 1
    end
    if n ~= #val then
      error("invalid table: sparse array")
    end
    -- Encode
    for i, v in ipairs(val) do
      table.insert(res, encode(v, stack))
    end
    stack[val] = nil
    return "[" .. table.concat(res, ",") .. "]"

  else
    -- Treat as an object
    for k, v in pairs(val) do
      if type(k) ~= "string" then
        error("invalid table: mixed or invalid key types")
      end
      table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
    end
    stack[val] = nil
    return "{" .. table.concat(res, ",") .. "}"
  end
end


local function encode_string(val)
  return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end


local function encode_number(val)
  -- Check for NaN, -inf and inf
  if val ~= val or val <= -math.huge or val >= math.huge then
    error("unexpected number value '" .. tostring(val) .. "'")
  end
  return string.format("%.14g", val)
end


local type_func_map = {
  [ "nil"     ] = encode_nil,
  [ "table"   ] = encode_table,
  [ "string"  ] = encode_string,
  [ "number"  ] = encode_number,
  [ "boolean" ] = tostring,
}


encode = function(val, stack)
  local t = type(val)
  local f = type_func_map[t]
  if f then
    return f(val, stack)
  end
  error("unexpected type '" .. t .. "'")
end

-----------------------------------------------------------
-- END OF json.lua
-----------------------------------------------------------

-- convert all strings into arrays 
local function normalize_value(v)
  return type(v) == "string" and ({ v }) or v
end

local function export_keymap()
  local copy_map = {}
  -- copy the keymap into a temporary table so we can sort it
  for k, v in pairs(keymap[conf.export_type]) do
    copy_map[#copy_map + 1] = { k, normalize_value(v) }
  end
  table.sort(copy_map, function(a, b) return a[1] < b[1] end)
  local output = encode(copy_map)

  if conf.destination == "doc" then
    -- open a doc containing the keymap so users can save it separately
    local d = core.open_doc(conf.export_type)
    core.root_view:open_doc(d)
    d:insert(1, 1, output)
    d.new_file = false
    d:clean()
  else
    -- export into a file
    local f, err = io.open(conf.destination, "w")
    if not f then
      core.error("cannot write to output: %s", err)
      return
    end

    f:write(output)
    f:close()
  end

  core.log("Keymap exported to %s.", conf.destination)

  if QUIT_AFTER_EXPORT then
    core.quit(true)
  end
end

command.add(nil, {
  ["keymap:export"] = export_keymap
})


core.add_thread(function()
  -- have to wait for the editor to start up!!!!
  -- or else settings will override this
  if conf.allow_env then
    -- check the following envs to override some settings
    if os.getenv("KEYMAP_EXPORT_TYPE") ~= nil then
      conf.export_type = os.getenv("KEYMAP_EXPORT_TYPE")
    end
    if os.getenv("KEYMAP_EXPORT_DESTINATION") ~= nil then
      conf.destination = os.getenv("KEYMAP_EXPORT_DESTINATION")
    end
    if os.getenv("KEYMAP_EXPORT_AUTOSTART") ~= nil then
      conf.autostart = os.getenv("KEYMAP_EXPORT_AUTOSTART") == "true"
    end
    if os.getenv("KEYMAP_EXPORT_QUIT_AFTER_EXPORT") ~= nil then
      QUIT_AFTER_EXPORT = os.getenv("KEYMAP_EXPORT_QUIT_AFTER_EXPORT") == "true"
    end
  end

  if conf.autostart then
    export_keymap()
  end
end)


--
-- json.lua
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
