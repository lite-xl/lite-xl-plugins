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
  parens = 5
}, config.plugins.rainbowparen)

style.syntax.paren_unbalanced = style.syntax.paren_unbalanced or { common.color "#DC0408" }
style.syntax.paren1  =  style.syntax.paren1 or { common.color "#FC6F71"}
style.syntax.paren2  =  style.syntax.paren2 or { common.color "#fcb053"}
style.syntax.paren3  =  style.syntax.paren3 or { common.color "#fcd476"}
style.syntax.paren4  =  style.syntax.paren4 or { common.color "#52dab2"}
style.syntax.paren5  =  style.syntax.paren5 or { common.color "#5a98cf"}

local closers = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}"
}

local function parenstyle(parenstack)
  return "paren" .. ((#parenstack % config.plugins.rainbowparen.parens) + 1)
end


local old_tokenize = DocView.tokenize
function DocView:tokenize(line)
  if not config.plugins.rainbowparen.enabled then
    return old_tokenize(self, line)
  end
  if not self.parenstack then self.parenstack = {} end
  local tokens = old_tokenize(self, line)
  local parenstack = self.parenstack[line-1] or ""
  local newtokens = {}
  -- split parens out
  -- the stock tokenizer can't do this because it merges identical adjacent tokens
  for idx, type, doc_line, col_start, col_end, line_style in self:each_token(tokens) do
    if type == "doc" and (line_style.type == "normal" or line_style.type == "symbol") then
      local text = self:get_token_text(type, doc_line, col_start, col_end)
      local offset = col_start
      for normtext1, paren, normtext2 in text:gmatch("([^%(%[{}%]%)]*)([%(%[{}%]%)]?)([^%(%[{}%]%)]*)") do
        if #normtext1 > 0 then
          table.insert(newtokens, "doc")
          table.insert(newtokens, doc_line)
          table.insert(newtokens, offset)
          table.insert(newtokens, offset + #normtext1 - 1)
          table.insert(newtokens, line_style)
          offset = offset + #normtext1
        end
        if #paren > 0 then
          table.insert(newtokens, "doc")
          table.insert(newtokens, doc_line)
          table.insert(newtokens, offset)
          table.insert(newtokens, offset)
          if paren == parenstack:sub(-1) then -- expected closer
            parenstack = parenstack:sub(1, -2)
            table.insert(newtokens, common.merge(line_style, { color = style.syntax[parenstyle(parenstack)] }))
          elseif closers[paren] then -- opener
            table.insert(newtokens, common.merge(line_style, { color = style.syntax[parenstyle(parenstack)] }))
            parenstack = parenstack .. closers[paren]
          else -- unexpected closer
            table.insert(newtokens, common.merge(line_style, { color = style.syntax["paren_unbalanced"] }))
          end
          offset = offset + #paren
        end
        if #normtext2 > 0 then
          table.insert(newtokens, "doc")
          table.insert(newtokens, doc_line)
          table.insert(newtokens, offset)
          table.insert(newtokens, offset + #normtext2 - 1)
          table.insert(newtokens, line_style)
          offset = offset + #normtext2
        end
      end
    else
      table.insert(newtokens, type)
      table.insert(newtokens, doc_line)
      table.insert(newtokens, col_start)
      table.insert(newtokens, col_end)
      table.insert(newtokens, line_style)
    end
  end
  if parenstack ~= self.parenstack[line] then
    self.parenstack[line] = parenstack
    if line < #self.doc.lines then self:invalidate_cache(line + 1) end
  end
  return newtokens
end

local function toggle_rainbowparen(enabled)
  config.plugins.rainbowparen.enabled = enabled
  for _, doc in ipairs(core.docs) do doc:reset_syntax() end
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
      toggle_rainbowparen(enabled)
    end
  }
}

command.add(nil, {
  ["rainbow-parentheses:toggle"] = function()
    toggle_rainbowparen(not config.plugins.rainbowparen.enabled)
  end
})
