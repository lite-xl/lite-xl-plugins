-- mod-version:3
local style = require "core.style"
local config = require "core.config"
local common = require "core.common"
local DocView = require "core.docview"

config.plugins.indentguide = common.merge({
  enabled = true,
  highlight = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Indent Guide",
    {
      label = "Enable",
      description = "Toggle the drawing of indentation indicator lines.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "Highlight Line",
      description = "Toggle the highlight of the curent indentation indicator lines.",
      path = "highlight",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.indentguide)

-- TODO: replace with `doc:get_indent_info()` when 2.1 releases
local function get_indent_info(doc)
  if doc.get_indent_info then
    return doc:get_indent_info()
  end
  return config.tab_type, config.indent_size
end


local function get_line_spaces(doc, line, dir)
  local _, indent_size = get_indent_info(doc)
  local text = doc.lines[line]
  if not text or #text == 1 then
    return -1
  end
  local s, e = text:find("^%s*")
  if e == #text then
    return get_line_spaces(doc, line + dir, dir)
  end
  local n = 0
  for _,b in pairs({text:byte(s, e)}) do
    n = n + (b == 9 and indent_size or 1)
  end
  return n
end


local function get_line_indent_guide_spaces(doc, line)
  if doc.lines[line]:find("^%s*\n") then
    return math.max(
      get_line_spaces(doc, line - 1, -1),
      get_line_spaces(doc, line + 1,  1))
  end
  return get_line_spaces(doc, line)
end

local docview_update = DocView.update
function DocView:update()
  docview_update(self)

  if not config.plugins.indentguide.enabled or not self:is(DocView) then
    return
  end

  local function get_indent(line)
    if line < 1 or line > #self.doc.lines then return -1 end
    if not self.indentguide_indents[line] then
      self.indentguide_indents[line] = get_line_indent_guide_spaces(self.doc, line)
    end
    return self.indentguide_indents[line]
  end

  self.indentguide_indents = {}
  self.indentguide_indent_active = {}

  local minline, maxline = self:get_visible_line_range()
  for i = minline, maxline do
    self.indentguide_indents[i] = get_line_indent_guide_spaces(self.doc, i)
  end

  local _, indent_size = get_indent_info(self.doc)
  for _,line in self.doc:get_selections() do
    local lvl = get_indent(line)
    local top, bottom

    if not self.indentguide_indent_active[line]
     or self.indentguide_indent_active[line] > lvl then

      -- check if we're the header or the footer of a block
      if get_indent(line + 1) > lvl and get_indent(line + 1) <= lvl + indent_size then
        top = true
        lvl = get_indent(line + 1)
      elseif get_indent(line - 1) > lvl and get_indent(line - 1) <= lvl + indent_size then
        bottom = true
        lvl = get_indent(line - 1)
      end

      self.indentguide_indent_active[line] = lvl

      -- check if the lines before the current are part of the block
      local i = line - 1
      if i > 0 and not top then
        repeat
          if get_indent(i) <= lvl - indent_size then break end
          self.indentguide_indent_active[i] = lvl
          i = i - 1
        until i < minline
      end
      -- check if the lines after the current are part of the block
      i = line + 1
      if i <= #self.doc.lines and not bottom then
        repeat
          if get_indent(i) <= lvl - indent_size then break end
          self.indentguide_indent_active[i] = lvl
          i = i + 1
        until i > maxline
      end
    end
  end
end


local draw_line_text = DocView.draw_line_text
function DocView:draw_line_text(line, x, y)
  if config.plugins.indentguide.enabled and self:is(DocView) then
    local spaces = self.indentguide_indents[line] or -1
    local _, indent_size = get_indent_info(self.doc)
    local w = math.max(1, SCALE)
    local h = self:get_line_height()
    local font = self:get_font()
    local space_sz = font:get_width(" ")
    for i = 0, spaces - 1, indent_size do
      local color = style.guide or style.selection
      local active_lvl = self.indentguide_indent_active[line] or -1
      if i < active_lvl 
      and i + indent_size >= active_lvl
      and config.plugins.indentguide.highlight then
        color = style.guide_highlight or style.accent
      end
      local sw = space_sz * i
      renderer.draw_rect(math.ceil(x + sw), y, w, h, color)
    end
  end
  return draw_line_text(self, line, x, y)
end
