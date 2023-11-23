-- mod-version:3
-- Author: Jipok
-- Doesn't work well with scaling mode == "ui"

local core = require "core"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local TreeView = require "plugins.treeview"
local Node = require "core.node"

-- Config
config.plugins.nonicons = common.merge({
  use_default_dir_icons = false,
  use_default_chevrons = false,
  draw_treeview_icons = true,
  draw_tab_icons = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Nonicons",
    {
      label = "Use Default Directory Icons",
      description = "When enabled does not use nonicon directory icons.",
      path = "use_default_dir_icons",
      type = "toggle",
      default = false
    },
    {
      label = "Use Default Chevrons",
      description = "When enabled does not use nonicon expand/collapse arrow icons.",
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
    }
  }
}, config.plugins.nonicons)

local icon_font = renderer.font.load(USERDIR.."/fonts/nonicons.ttf", 15 * SCALE)
local chevron_width = icon_font:get_width("")
local previous_scale = SCALE
local extension_icons = {
  [".lua"] = { "#51a0cf", "" },
  [".md"]  = { "#519aba", "" }, -- Markdown
  [".cpp"] = { "#519aba", "" },
  [".c"]   = { "#599eff", "" },
  [".h"] = { "#599eff", "" },
  [".py"]  = { "#3572A5", "" }, -- Python
  [".pyc"]  = { "#519aba", "" }, [".pyd"]  = { "#519aba", "" },
  [".php"] = { "#a074c4", "" },
  [".cs"] = { "#596706", "" },  -- C#
  [".conf"] = { "#6d8086", "" }, [".cfg"] = { "#6d8086", "" },
  [".toml"] = { "#6d8086", "" },
  [".yaml"] = { "#6d8086", "" }, [".yml"] = { "#6d8086", "" },
  [".json"] = { "#854CC7", "" },
  [".css"] = { "#563d7c", "" },
  [".html"] = { "#e34c26", "" },
  [".js"] = { "#cbcb41", "" },  -- JavaScript
  [".go"] = { "#519aba", "" },
  [".jpg"] = { "#a074c4", "" }, [".png"] = { "#a074c4", "" },
  [".sh"] = { "#4d5a5e", "" },  -- Shell
  [".java"] = { "#cc3e44", "" },
  [".scala"] = { "#cc3e44", "" },
  [".kt"] = { "#F88A02", "" },  -- Kotlin
  [".pl"] = { "#519aba", "" }, [".pm"] = { "#519aba", "" },  -- Perl
  [".r"] = { "#358a5b", "" },
  [".rake"] = { "#701516", "" },
  [".rb"] = { "#701516", "" },  -- Ruby
  [".rs"] = { "#dea584", "" },  -- Rust
  [".rss"] = { "#cc3e44", "" },
  [".sql"] = { "#dad8d8", "" },
  [".swift"] = { "#e37933", "" },
  [".ts"] = { "#519aba", "" },  -- TypeScript
  [".elm"] = { "#519aba", "" },
  [".diff"] = { "#41535b", "" },
  [".ex"] = { "#a074c4", "" }, [".exs"] = { "#a074c4", "" },  -- Elixir
  -- Following without special icon:
  [".awk"] = { "#4d5a5e", "" },
  [".nim"] = { "#F88A02", "" },
  [".zig"] = { "#cbcb41", "" },
  -- START: Adding per https://github.com/lite-xl/lite-xl-plugins/issues/144
  [".vim"] = { "#8f00ff", "" },
  [".j2"] = { "#ffff00", "" },
  [".ini"] = { "#ffffff", "" },
  [".fish"] = { "#ca2c92", "" },
  [".bash"] = { "#4169e1", "" },
  -- END: Adding per https://github.com/lite-xl/lite-xl-plugins/issues/144
}
local known_names_icons = {
  ["changelog"] = { "#657175", "" }, ["changelog.txt"] = { "#4d5a5e", "" },
  ["changelog.md"] = { "#519aba", "" },
  ["makefile"] = { "#6d8086", "" },
  ["dockerfile"] = { "#296478", "" },
  ["docker-compose.yml"] = { "#4289a1", "" },
  ["license"] = { "#d0bf41", "" },
  ["cmakelists.txt"] = { "#6d8086", "" },
  ["readme.md"] = { "#72b886", "" }, ["readme"] = { "#72b886", "" },
  ["init.lua"] = { "#2d6496", "" },
  ["setup.py"] = { "#559dd9", "" },
  ["build.zig"] = { "#6d8086", "" },
}

-- Preparing colors
for k, v in pairs(extension_icons) do
  v[1] = { common.color(v[1]) }
end
for k, v in pairs(known_names_icons) do
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
    chevron_width = icon_font:get_width("")
    previous_scale = SCALE
  end
  if not config.plugins.nonicons.use_default_dir_icons then
    icon = "" -- unicode 61766
    font = icon_font
    color = style.text
    if item.type == "dir" then
      icon = item.expanded and "" or "" -- unicode U+F23C and U+F23B
    end
  end
  if config.plugins.nonicons.draw_treeview_icons then
    local custom_icon = known_names_icons[item.name:lower()]
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
  if not config.plugins.nonicons.use_default_chevrons then
    if item.type == "dir" then
      local chevron_icon = item.expanded and "" or ""
      local chevron_color = hovered and style.accent or style.text
      common.draw_text(icon_font, chevron_color, chevron_icon, nil, x, y, 0, h)
    end
    return chevron_width + style.padding.x/4
  end
  return TreeView_draw_item_chevron(self, item, active, hovered, x, y, w, h)
end

-- Override function to draw icons in tabs titles if setting is enabled
local Node_draw_tab_title = Node.draw_tab_title
function Node:draw_tab_title(view, font, is_active, is_hovered, x, y, w, h)
  if config.plugins.nonicons.draw_tab_icons then
    local padx = chevron_width + style.padding.x/2
    local tx = x + padx -- Space for icon
    w = w - padx
    Node_draw_tab_title(self, view, font, is_active, is_hovered, tx, y, w, h)
    if (view == nil) or (view.doc == nil) then return end
    local item = { type = "file", name = view.doc:get_name() }
    TreeView:draw_item_icon(item, false, is_hovered, x, y, w, h)
  else
    Node_draw_tab_title(self, view, font, is_active, is_hovered, x, y, w, h)
  end
end
