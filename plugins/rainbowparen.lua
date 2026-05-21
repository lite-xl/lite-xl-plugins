-- mod-version:4
local core = require "core"
local style = require "core.style"
local config = require "core.config"
local common = require "core.common"
local command = require "core.command"
local tokenizer = require "core.tokenizer"
local DocView = require "core.docview"

config.plugins.rainbowparen = common.merge({
  enabled = true,
}, config.plugins.rainbowparen)

style.syntax.paren_unbalanced = style.syntax.paren_unbalanced or { common.color "#DC0408" }
style.syntax.paren1  =  style.syntax.paren1 or { common.color "#FC6F71"}
style.syntax.paren2  =  style.syntax.paren2 or { common.color "#fcb053"}
style.syntax.paren3  =  style.syntax.paren3 or { common.color "#fcd476"}
style.syntax.paren4  =  style.syntax.paren4 or { common.color "#52dab2"}
style.syntax.paren5  =  style.syntax.paren5 or { common.color "#5a98cf"}

local total_parens = 5
while style.syntax["paren" .. (total_parens + 1)] do 
  total_parens = total_parens + 1
end

local closers = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}"
}

local old_tokenize = DocView.tokenize
function DocView:tokenize(line, ...)
  if not config.plugins.rainbowparen.enabled then return old_tokenize(self, line, ...) end
  if not self.parenstack then self.parenstack = {} end
  local parenstack = self.parenstack[line-1] or ""
  local t = common.accumulate_tokens(old_tokenize(self, line, ...), function(output, text, token_style)
    if token_style.type == "normal" or token_style.type == "symbol" then
      for normtext1, paren, normtext2 in text:gmatch("([^%(%[{}%]%)]*)([%(%[{}%]%)]?)([^%(%[{}%]%)]*)") do
        if #normtext1 > 0 then output(normtext1) end
        if #paren > 0 then
          local color
          if paren == parenstack:sub(-1) then -- expected closer
            parenstack = parenstack:sub(1, -2)
            color = "paren" .. ((#parenstack % total_parens) + 1)
          elseif closers[paren] then -- opener
            color = "paren" .. ((#parenstack % total_parens) + 1)
            parenstack = parenstack .. closers[paren]
          end
          output(paren, { color = style.syntax[color or "paren_unbalanced"] })
        end
        if #normtext2 > 0 then output(normtext2) end
      end
    else
      output(text)
    end
  end)
  if parenstack ~= self.parenstack[line] then
    self.parenstack[line] = parenstack
    if line < #self.doc.lines then self:invalidate_cache(line + 1) end
  end
  return t
end

-- The config specification used by the settings gui
config.plugins.rainbowparen.config_spec = {
  name = "Rainbow Parentheses",
  {
    label = "Enable",
    description = "Activates rainbow parenthesis coloring by default.",
    path = "enabled",
    type = "toggle",
    default = true,
    on_apply = function(enabled)
      command.perform("rainbow-parentheses:toggle", enabled)
    end
  }
}

command.add(nil, {
  ["rainbow-parentheses:toggle"] = function(enabled)
    if enabled == nil then enabled = not config.plugins.rainbowparen.enabled end
    config.plugins.rainbowparen.enabled = enabled
    for _, doc in ipairs(core.docs) do doc:reset_syntax() end
  end
})
