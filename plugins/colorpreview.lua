-- mod-version:4 priority: 2000
local config = require "core.config"
local common = require "core.common"
local DocView = require "core.docview"


config.plugins.colorpreview = common.merge({
  enabled = true,
  -- The config specification used by the settings gui
  config_spec = {
    name = "Color Preview",
    {
      label = "Enable",
      description = "Enable or disable the color preview feature.",
      path = "enabled",
      type = "toggle",
      default = true
    }
  }
}, config.plugins.colorpreview)

local white = { common.color "#ffffff" }
local black = { common.color "#000000" }

local function style_pattern(dv, line, tokens, pattern, base, multiplier)
  local offset = 1
  while offset < line do
    local s, e, r, g, b, a = dv.doc.lines[line]:ufind(pattern, offset)
    if not s then break end
    if not a or a == "" then a = 255 else a = tonumber(a, base) end
    r, g, b = tonumber(r, base), tonumber(g, base), tonumber(b, base)
    r, g, b = r * multiplier, g * multiplier, b * multiplier
    local text_color = math.max(r, g, b) < 128 and white or black
    tokens = common.paint_tokens(tokens, s, e, { background = { r, g, b, a }, color = text_color })
    offset = e + 1
  end
  return tokens
end

local old_tokenize = DocView.tokenize
function DocView:tokenize(line, ...)
  local tokens = old_tokenize(self, line, ...)
  tokens = style_pattern(self, line, tokens, "#(%x%x)(%x%x)(%x%x)(%x?%x?)%f[%W]", 16, 1)
  tokens = style_pattern(self, line, tokens, "#(%x)(%x)(%x)%f[%W]", 16, 16)
  tokens = style_pattern(self, line, tokens, "rgba?%((%d+)%D+(%d+)%D+(%d+)[%s,]-([%.%d]-)%s-%)", 10, 1)
  return tokens
end

