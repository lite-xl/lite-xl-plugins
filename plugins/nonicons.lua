-- mod-version:3
-- Author: Jipok
-- Doesn't work well with scaling mode == "ui"

local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local TreeView = require "plugins.treeview"
local Node = require "core.node"

local nonicons = require "libraries.font_nonicons"

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

local icon_font = renderer.font.load(nonicons.path, 15 * SCALE)
local map = nonicons.utf8
local chevron_width = icon_font:get_width(map["chevron-down-16"])
local previous_scale = SCALE
local extension_icons = {
  [".lua"] = { "#51a0cf", "lua-16" },
  [".md"]  = { "#519aba", "markdown-16" }, -- Markdown
  [".cpp"] = { "#519aba", "c-plusplus-16" },
  [".c"]   = { "#599eff", "c-16" },
  [".h"] = { "#599eff", "heading-16" },
  [".py"]  = { "#3572A5", "python-16" }, -- Python
  [".pyc"]  = { "#519aba", "python-16" }, [".pyd"]  = { "#519aba", "python-16" },
  [".php"] = { "#a074c4", "php-16" },
  [".cs"] = { "#596706", "c-sharp-16" },  -- C#
  [".conf"] = { "#6d8086", "gear-16" }, [".cfg"] = { "#6d8086", "gear-16" },
  [".toml"] = { "#6d8086", "toml-16" },
  [".yaml"] = { "#6d8086", "yaml-16" }, [".yml"] = { "#6d8086", "yaml-16" },
  [".json"] = { "#854CC7", "json-16" },
  [".css"] = { "#563d7c", "css-16" },
  [".html"] = { "#e34c26", "html-16" },
  [".js"] = { "#cbcb41", "javascript-16" }, [".cjs"] = { "#cbcb41", "javascript-16" }, [".mjs"] = { "#cbcb41", "javascript-16" },  -- JavaScript
  [".go"] = { "#519aba", "go-16" },
  [".jpg"] = { "#a074c4", "image-16" }, [".png"] = { "#a074c4", "image-16" },
  [".sh"] = { "#4d5a5e", "terminal-16" },  -- Shell
  [".java"] = { "#cc3e44", "java-16" },
  [".scala"] = { "#cc3e44", "scala-16" },
  [".kt"] = { "#F88A02", "kotlin-16" },  -- Kotlin
  [".pl"] = { "#519aba", "perl-16" }, [".pm"] = { "#519aba", "perl-16" },  -- Perl
  [".r"] = { "#358a5b", "r-16" },
  [".rake"] = { "#701516", "ruby-16" },
  [".rb"] = { "#701516", "ruby-16" },  -- Ruby
  [".rs"] = { "#dea584", "rust-16" },  -- Rust
  [".rss"] = { "#cc3e44", "rss-16" },
  [".sql"] = { "#dad8d8", "database-16" },
  [".swift"] = { "#e37933", "swift-16" },
  [".ts"] = { "#519aba", "typescript-16" },  -- TypeScript
  [".elm"] = { "#519aba", "elm-16" },
  [".diff"] = { "#41535b", "file-diff-16" },
  [".ex"] = { "#a074c4", "elixir-16" }, [".exs"] = { "#a074c4", "elixir-16" },  -- Elixir
  [".vim"] = { "#8f00ff", "vim-16" },
  -- Following without special icon:
  [".awk"] = { "#4d5a5e", "code-16" },
  [".nim"] = { "#F88A02", "code-16" },
  [".zig"] = { "#cbcb41", "code-16" },
  [".j2"] = { "#ffff00", "milestone-16" },
  [".ini"] = { "#ffffff", "pencil-16" },
  [".fish"] = { "#ca2c92", "terminal-16" },
  [".bash"] = { "#4169e1", "terminal-16" },
}
local known_names_icons = {
  ["changelog"] = { "#657175", "history-16" }, ["changelog.txt"] = { "#4d5a5e", "history-16" },
  ["changelog.md"] = { "#519aba", "history-16" },
  ["makefile"] = { "#6d8086", "terminal-16" },
  ["dockerfile"] = { "#296478", "docker-16" },
  ["docker-compose.yml"] = { "#4289a1", "docker-16" },
  ["license"] = { "#d0bf41", "file-badge-16" },
  ["cmakelists.txt"] = { "#6d8086", "gear-16" },
  ["readme.md"] = { "#72b886", "file-16" }, ["readme"] = { "#72b886", "file-16" },
  ["init.lua"] = { "#2d6496", "lua-16" },
  ["setup.py"] = { "#559dd9", "python-16" },
  ["build.zig"] = { "#6d8086", "gear-16" },
}

-- Preparing colors
for _, v in pairs(extension_icons) do
  v[1] = { common.color(v[1]) }
end
for _, v in pairs(known_names_icons) do
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
    chevron_width = icon_font:get_width(map["chevron-down-16"])
    previous_scale = SCALE
  end
  if not config.plugins.nonicons.use_default_dir_icons then
    icon = map["file-16"] -- unicode 61766
    font = icon_font
    color = style.text
    if item.type == "dir" then
      icon = item.expanded and map["file-directory-open-fill-16"] or map["file-directory-fill-16"] -- unicode U+F23C and U+F23B
    end
  end
  if config.plugins.nonicons.draw_treeview_icons then
    local custom_icon = known_names_icons[item.name:lower()]
    if custom_icon == nil then
      custom_icon = extension_icons[item.name:match("^.+(%..+)$")]
    end
    if custom_icon ~= nil then
      color = custom_icon[1]
      icon = map[custom_icon[2]]
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
      local chevron_icon = item.expanded and "chevron-down-16" or "chevron-right-16"
      local chevron_color = hovered and style.accent or style.text
      common.draw_text(icon_font, chevron_color, map[chevron_icon], nil, x, y, 0, h)
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
