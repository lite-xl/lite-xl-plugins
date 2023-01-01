-- mod-version:3
local core = require "core"
local command = require "core.command"
local DocView = require "core.docview"


local function exec(cmd, keep_newline)
  local fp = io.popen(cmd, "r")
  local res = fp:read("*a")
  fp:close()
  return keep_newline and res or res:gsub("%\n$", "")
end


local function get_active_view()
  if getmetatable(core.active_view) == DocView then
    return core.active_view
  end
  return nil
end


local function execw(cmd, v, keep_newline)
  local fp = io.popen(cmd, "w")
  fp:write(tostring(v))
  fp:close()
end


local function exec_doc(cmd, keep_newline)
  local tmp = exec("mktemp -t lite-xl.tmp.XXXXXXXXXX", false)
  local av_doc = get_active_view().doc
  execw(cmd .. " 2>&1 >" .. tmp, av_doc, keep_newline)

  return exec("cat " .. tmp, keep_newline)
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
            "printf %b " .. printfb_quote(str:gsub("%\n$", "") .. "\n") .. " | eval '' " .. shell_quote(cmd),
            str:find("%\n$")
          )
        end)
      end
    })
  end,

  ["exec:replace-from-document"] = function(dv)
    core.command_view:enter("Replace With Result Of Command From Piped Document Content", {
      submit = function(cmd)
        dv.doc:replace(function(str)
          return exec_doc(
            "printf %b " .. printfb_quote(str:gsub("%\n$", "") .. "\n") .. " | eval '' " .. shell_quote(cmd),
            str:find("%\n$")
          )
        end)
      end
    })
  end,
})
