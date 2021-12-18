-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local common = require "core.common"
local style = require "core.style"
local TreeView = require "plugins.treeview"


local icon_font = renderer.font.load(USERDIR.."/fonts/nonicons.ttf", 15 * SCALE)
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
  [".pl"] = { "#519aba", "" },  -- Perl
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

}
local known_names_icons = {
  ["changelog"] = { "#657175", "" }, ["changelog.txt"] = { "#4d5a5e", "" },
  ["makefile"] = { "#6d8086", "" },
  ["dockerfile"] = { "#296478", "" },
  ["docker-compose.yml"] = { "#4289a1", "" },
  ["license"] = { "#d0bf41", "" },
  ["cmakelists.txt"] = { "#6d8086", "" },
  ["readme.md"] = { "#72b886", "" }, ["readme"] = { "#72b886", "" },
  ["init.lua"] = { "#2d6496", "" },
  ["setup.py"] = { "#559dd9", "" },
}

-- Preparing colors
for k, v in pairs(extension_icons) do
  v[1] = { common.color(v[1]) }
end
for k, v in pairs(known_names_icons) do
  v[1] = { common.color(v[1]) }
end

-- Replace original draw
function TreeView:draw()
  self:draw_background(style.background2)

  local icon_width = icon_font:get_width("")
  local spacing = icon_font:get_width("") / 2

  local doc = core.active_view.doc
  local active_filename = doc and system.absolute_path(doc.filename or "")

  for item, x,y,w,h in self:each_item() do
    local color = style.text

    -- highlight active_view doc
    if item.abs_filename == active_filename then
      color = style.accent
    end

    -- hovered item background
    if item == self.hovered_item then
      renderer.draw_rect(x, y, w, h, style.line_highlight)
      color = style.accent
    end

    -- icons
    x = x + item.depth * style.padding.x + style.padding.x
    if item.type == "dir" then
      local icon1 = item.expanded and "" or "" -- unicode 61726 and 61728
      local icon2 = item.expanded and "" or "" -- unicode 61771 and 61772
      x = x - spacing
      common.draw_text(icon_font, color, icon1, nil, x, y, 0, h)
      x = x + style.padding.x + spacing
      common.draw_text(icon_font, color, icon2, nil, x, y, 0, h)
      x = x + icon_width
    else
      x = x + style.padding.x
      -- default icon
      local icon = "" -- unicode 61766
      local icon_color = color
      -- icon depending on the file extension or full name
      local custom_icon = known_names_icons[item.name:lower()]
      if custom_icon == nil then
        custom_icon = extension_icons[item.name:match("^.+(%..+)$")]
      end
      if custom_icon ~= nil then
        icon_color = custom_icon[1]
        icon = custom_icon[2]
      end
      common.draw_text(icon_font, icon_color, icon, nil, x, y, 0, h)
      x = x + icon_width
    end

    -- text
    x = x + spacing
    x = common.draw_text(style.font, color, item.name, nil, x, y, 0, h)
  end

  self:draw_scrollbar()
  if self.hovered_item and self.tooltip.alpha > 0 then
    core.root_view:defer_draw(self.draw_tooltip, self)
  end
end

