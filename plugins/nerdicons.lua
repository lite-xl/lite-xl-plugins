-- mod-version:3
-- Orginal Author: Jipok
-- Modified by: techie-guy
-- Doesn't work well with scaling mode == "ui"

-- This is an extension/modification of the nonicons plugin, https://github.com/lite-xl/lite-xl-plugins/blob/master/plugins/nonicons.lua

-- Any icon can be searched by it's hex from nerdfonts.com/cheat-sheet

-- How to use:
-- 1. Download a nerd font that you like from nerdfonts.com
-- 2. Unzip the zip file that you downloaded.
-- 3. Choose a font file from the unzipped directory and install it.
-- 4. Copy the font file to the .config/lite-xl/fonts and rename it to "icon-nerd-font.ttf".
-- 5. Restart lite-xl, the icons should appear.

local core = require "core"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local TreeView = require "plugins.treeview"
local Node = require "core.node"

-- Config
config.plugins.nerdicons = common.merge({
  use_default_dir_icons = false,
  use_default_chevrons = false,
  draw_treeview_icons = true,
  draw_tab_icons = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Nerdicons",
    {
      label = "Use Default Directory Icons",
      description = "When enabled does not use nerdicon directory icons.",
      path = "use_default_dir_icons",
      type = "toggle",
      default = false
    },
    {
      label = "Use Default Chevrons",
      description = "When enabled does not use nerdicon expand/collapse arrow icons.",
      path = "use_default_chevrons",
      type = "toggle",
      default = false
    },
    {
      label = "Draw Treeview Icons",
      description = "Enables file related icons on the treeview.",
      path = "draw_treeview_icons",
      type = "toggle",
      default = true
    },
    {
      label = "Draw Tab Icons",
      description = "Adds file related icons to tabs.",
      path = "draw_tab_icons",
      type = "toggle",
      default = true
    },
  }
}, config.plugins.nerdicons)

local icon_font = renderer.font.load(USERDIR .. "/fonts/icon-nerd-font.ttf", 18.5 * SCALE)
local chevron_width = icon_font:get_width("")
local previous_scale = SCALE

local extension_icons = {
  [".lua"] = { "#405af0", ""},
  [".md"]  = { "#519aba", "" }, -- Markdown
  [".powershell"] = { "#519aba", "" },
  [".bat"] = { "#cbcb41", "" },
  [".txt"] = { "#ffffff", "" },
  [".cpp"] = { "#519aba", "ﭱ" },
  [".c"]   = { "#599eff", "" },
  [".h"]   = { "#79029b", "h" },
  [".hpp"] = { "#79029b", "h" },
  [".py"]  = { "#3572A5", "" }, -- Python
  [".pyc"]  = { "#519aba", "" },
  [".pyd"]  = { "#519aba", "" },
  [".php"] = { "#a074c4", "" },
  [".cs"] = { "#596706", "" },  -- C#
  [".conf"] = { "#6d8086", "" }, [".cfg"] = { "#6d8086", "" },
  [".toml"] = { "#6d8086", "" },
  [".yaml"] = { "#6d8086", "" }, [".yml"] = { "#6d8086", "" },
  [".json"] = { "#854CC7", "" },
  [".css"] = { "#519abc", "" },
  [".html"] = { "#e34c26", "" },
  [".js"] = { "#cbcb41", "" },  -- JavaScript
  [".go"] = { "#519aba", "" },
  [".jpg"] = { "#a074c4", "" }, [".png"] = { "#a074c4", "" },
  [".sh"] = { "#4d5a5e", "" }, [".bash"] = { "#4d5a5e", "" },  -- Shell
  [".java"] = { "#cc3e44", "" },
  [".scala"] = { "#cc3e44", "" },
  [".kt"] = { "#F88A02", "" },  -- Kotlin
  [".pl"] = { "#519aba", "" }, [".pm"] = { "#519aba", "" },  -- Perl
  [".rb"] = { "#701516", "" },  -- Ruby
  [".rs"] = { "#c95625", "" },  -- Rust
  [".rss"] = { "#cc3e44", "" },
  [".sql"] = { "#dad8d8", "" },
  [".swift"] = { "#e37933", "ﯣ" },
  [".ts"] = { "#519aba", "ﯤ" },  -- TypeScript
  [".diff"] = { "#41535b", "" },
  [".exe"] = {"#cc3e55", ""},
  [".make"] = { "#d0bf41", "" },
  [".svg"] = { "#f7ca39", "ﰟ" },
  [".ttf"] = {"#dad8d4", ""}, [".otf"] = {"#dad8d4", ""}
}

local known_filenames_icons = {
  ["dockerfile"] = { "#296478", "" },
  [".gitignore"] = { "#cc3e55", "" },
  [".gitmodules"] = { "#cc3e56", "" },
  ["PKGBUILD"] = { "#6d8ccc", "" },
  ["license"] = { "#d0bf41", "" },
  ["makefile"] = { "#d0bf41", "" },
  ["cmakelists.txt"] = { "#cc3e55", "喝" },
}

-- Preparing colors
for k, v in pairs(extension_icons) do
  v[1] = { common.color(v[1]) }
end
for k, v in pairs(known_filenames_icons) do
  v[1] = { common.color(v[1]) }
end

-- Override function to change default icons for dirs, special extensions and names
local TreeView_get_item_icon = TreeView.get_item_icon
function TreeView:get_item_icon(item, active, hovered)
  local icon, font, color = TreeView_get_item_icon(self, item, active, hovered)
  if previous_scale ~= SCALE then
    icon_font:set_size(
      icon_font:get_size() * (SCALE / previous_scale)
    )
    chevron_width = icon_font:get_width("")
    previous_scale = SCALE
  end
  if not config.plugins.nerdicons.use_default_dir_icons then
    icon = "" -- hex ea7b
    font = icon_font
    color = style.text
    if item.type == "dir" then
      icon = item.expanded and "ﱮ" or "" -- hex f07c and f07b
    end
  end
  if config.plugins.nerdicons.draw_treeview_icons then
    local custom_icon = known_filenames_icons[item.name:lower()]
    if custom_icon == nil then
      custom_icon = extension_icons[item.name:match("^.+(%..+)$")]
    end
    if custom_icon ~= nil then
      color = custom_icon[1]
      icon = custom_icon[2]
      font = icon_font
    end
    if active or hovered then
      color = style.accent
    end
  end
  return icon, font, color
end

-- Override function to draw chevrons if setting is disabled
local TreeView_draw_item_chevron = TreeView.draw_item_chevron
function TreeView:draw_item_chevron(item, active, hovered, x, y, w, h)
  if not config.plugins.nerdicons.use_default_chevrons then
    if item.type == "dir" then
      local chevron_icon = item.expanded and "" or ""
      local chevron_color = hovered and style.accent or style.text
      common.draw_text(icon_font, chevron_color, chevron_icon, nil, x+8, y, 0, h) -- added 8 to x to draw the chevron closer to the icon
    end
    return chevron_width + style.padding.x
  end
  return TreeView_draw_item_chevron(self, item, active, hovered, x, y, w, h)
end

-- Override function to draw icons in tabs titles if setting is enabled
local Node_draw_tab_title = Node.draw_tab_title
function Node:draw_tab_title(view, font, is_active, is_hovered, x, y, w, h)
  if config.plugins.nerdicons.draw_tab_icons then
    local padx = chevron_width + style.padding.x/2
    local tx = x + padx/16 -- Space for icon
    w = w + padx
    Node_draw_tab_title(self, view, font, is_active, is_hovered, tx, y, w, h)
    if (view == nil) or (view.doc == nil) then return end
    local item = { type = "file", name = view.doc:get_name() }
    TreeView:draw_item_icon(item, false, is_hovered, x, y, w, h)
  else
    Node_draw_tab_title(self, view, font, is_active, is_hovered, x, y, w, h)
  end
end
