-- mod-version:3
local core = require "core"
local command = require "core.command"


local function exec(cmd, keep_newline)
  local fp = io.popen(cmd, "r")
  local res = fp:read("*a")
  fp:close()
  return keep_newline and res or res:gsub("%\n$", "")
end


local function shell_quote(str)
  return "'" .. str:gsub("'", "'\\''") .. "'"
end


local printfb_sub = {
  ["\\"] = "\\\\",
  ["\0"] = "\\0000",
  ["'"] = "'\\''",
}
local function printfb_quote(str)
  return "'" .. str:gsub(".", printfb_sub) .. "'"
end


command.add("core.docview", {
  ["exec:insert"] = function(dv)
    core.command_view:enter("Insert Result Of Command", {
      submit = function(cmd)
        dv.doc:text_input(exec(cmd))
      end
    })
  end,

  ["exec:replace"] = function(dv)
    core.command_view:enter("Replace With Result Of Command", {
      submit = function(cmd)
        dv.doc:replace(function(str)
          return exec(
            "printf %b " .. printfb_quote(str:gsub("%\n$", "") .. "\n") ..
            " | eval '' " .. shell_quote(cmd:gmatch("%?%?", str)),
            str:find("%\n$")
          )
        end)
      end
    })
  end,
})
