-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local common = require "core.common"
local style = require "core.style"
local ContextMenu = require "core.contextmenu"
local RootView = require "core.rootview"
local TreeView = require "plugins.treeview"


local original_draw = TreeView.draw
local icon_font = renderer.font.load(USERDIR .. "/fonts/nonicons.ttf", 15 * SCALE)

local icons = {
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

    -- allow for color overrides
    local icon_color = self:color_for_item(item.abs_filename) or color

    -- icons
    x = x + item.depth * style.padding.x + style.padding.x
    if item.type == "dir" then
      local icon1 = item.expanded and "" or "" -- 61726 and 61728
      local icon2 = item.expanded and "" or "" -- 61771 and 61772
      x = x - spacing
      common.draw_text(icon_font, color, icon1, nil, x, y, 0, h)
      x = x + style.padding.x + spacing
      common.draw_text(icon_font, color, icon2, nil, x, y, 0, h)
      x = x + icon_width
    else
      x = x + style.padding.x
      local icon = ""
      local ext = item.name:match("^.+(%..+)$")
      if icons[ext] ~= nil then
        icon_color = { common.color(icons[ext][1]) }
        icon = icons[ext][2]
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


