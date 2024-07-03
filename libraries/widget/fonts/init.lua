local core = require "core"
local common = require "core.common"
local style = require "core.style"
local FontCache = require "libraries.widget.fonts.cache"
local StatusView = require "core.statusview"

---@class widget.fonts
local Fonts = {}

---@type widget.fonts.cache | nil
local fontcache = nil

---@type table<integer, string> | nil
local fonts = nil

---Last time the status view item was rendered
local last_statusview_render = 0

---The amount of fonts matching the user query
local matching_fonts = 0

---Flag that indicates if command view font picker is for monospaced
local pick_monospaced = false

---Generate the list of fonts displayed on the CommandView.
---@param monospaced? boolean Only display fonts detected as monospaced.
local function generate_fonts(monospaced)
  if fontcache then
    if fontcache.building then monospaced = false end
    fonts = {}
    for idx, f in ipairs(fontcache.fonts) do
      if not monospaced or (monospaced and f.monospace) then
        table.insert(fonts, f.fullname .. "||" .. idx)
      end
    end
  end
end

---Helper function to split a string by a given delimeter.
local function split(s, delimeter, delimeter_pattern)
  if not delimeter_pattern then
    delimeter_pattern = delimeter
  end

  local result = {};
  for match in (s..delimeter):gmatch("(.-)"..delimeter_pattern) do
    table.insert(result, match);
  end
  return result;
end

local already_cleaning = false

---Clean the generated font cache used on command view to free some ram
local function clean_fonts_cache()
  if not fontcache or already_cleaning then return end
  if not fontcache.building and not fontcache.searching_monospaced then
    fontcache = nil
    fonts = nil
    collectgarbage "collect"
  else
    already_cleaning = true
    core.add_thread(function()
      while fontcache.building or fontcache.searching_monospaced do
        coroutine.yield(1)
      end
      if
        core.active_view ~= core.command_view
        or
        (
          core.command_view.label ~= "Select Font: "
          and
          core.command_view.label ~= "List only monospaced fonts?: "
        )
      then
        fontcache = nil
        fonts = nil
        collectgarbage "collect"
        already_cleaning = false
      end
    end)
  end
end

---Launch the commandview and let the user select a font.
---@param callback fun(name:string, path:string)
---@param monospaced boolean
function Fonts.show_picker(callback, monospaced)
  if not fontcache then fontcache = FontCache() end

  pick_monospaced = monospaced

  if not fontcache.building and (not monospaced or fontcache.monospaced) then
    generate_fonts(monospaced)
  else
    core.add_thread(function()
      while
        (fontcache.building or (monospaced and not fontcache.monospaced))
        and
        core.active_view == core.command_view
        and
        core.command_view.label == "Select Font: "
      do
        core.command_view:update_suggestions()
        coroutine.yield(2)
      end
      generate_fonts(monospaced)
      core.command_view:update_suggestions()
    end)
  end

  last_statusview_render = system.get_time()

  core.command_view:enter("Select Font", {
    submit = function(text, item)
      callback(item.text, item.info)
      clean_fonts_cache()
    end,
    suggest = function(text)
      if fontcache.building or (monospaced and fontcache.searching_monospaced) then
        generate_fonts(monospaced)
      end
      local res = common.fuzzy_match(fonts, text)
      matching_fonts = #res
      for i, name in ipairs(res) do
        local font_info = split(name, "||")
        local id = tonumber(font_info[2])
        local font_data = fontcache.fonts[id]
        res[i] = {
          text = font_data.fullname,
          info = font_data.path,
          id = id
        }
      end
      return res
    end,
    cancel = function()
      clean_fonts_cache()
    end
  })
end

---Same as `show_picker()` but asks the user if he wants a monospaced font.
---@param callback fun(name:string, path:string)
function Fonts.show_picker_ask_monospace(callback)
  if not fontcache then fontcache = FontCache() end

  core.command_view:enter("List only monospaced fonts?", {
    submit = function(text, item)
      Fonts.show_picker(callback, item.mono)
    end,
    suggest = function(text)
      local res = common.fuzzy_match({"Yes", "No"}, text)
      for i, name in ipairs(res) do
        res[i] = {
          text = name,
          mono = text == "Yes" and true or false
        }
      end
      return res
    end,
    cancel = function()
      clean_fonts_cache()
    end
  })
end

---Check if the font cache is been built.
---@return boolean building
function Fonts.cache_is_building()
  if not fontcache then return false end
  return fontcache:is_building()
end

---Remove current fonts cache file and regenerates a fresh one.
---@return boolean started False if cache is already been built
function Fonts.clean_cache()
  if not fontcache then fontcache = FontCache() end
  return fontcache:rebuild()
end

core.status_view:add_item({
  predicate = function()
    return core.active_view == core.command_view
      and core.command_view.label == "Select Font: "
  end,
  name = "widget:font-select",
  alignment = StatusView.Item.LEFT,
  get_item = function()
    local found = 0
    local dots, status = "", ""
    if fontcache then
      if fontcache.building or fontcache.searching_monospaced then
        dots = "."
        if system.get_time() - last_statusview_render >= 3 then
          last_statusview_render = system.get_time()
        elseif system.get_time() - last_statusview_render >= 2 then
          dots = "..."
        elseif system.get_time() - last_statusview_render >= 1 then
          dots = ".."
        end
      end
      if fontcache.building then
        status = " | searching system fonts" .. dots
      elseif fontcache.searching_monospaced then
        status = " | detecting monospaced fonts" .. dots
      end

      if fontcache.building or not pick_monospaced then
        found = fontcache.found
      else
        found = fontcache.found_monospaced
      end
    end

    return {
      style.text,
      style.font,
      "Matches: "
        .. tostring(matching_fonts)
        .. " / "
        .. tostring(found)
        .. status
    }
  end,
  position = 1
})


return Fonts
