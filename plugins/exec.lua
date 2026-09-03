-- mod-version:3
local core = require "core"
local command = require "core.command"


local function exec(cmd, keep_newline)
  local fp = io.popen(cmd, "r")
  local res = fp:read("*a")
  fp:close()
  return keep_newline and res or res:gsub("%\n$", "")
end


local function exec_rw(cmd, keep_newline, str)
  local proc = process.start { "sh", "-c", cmd }
  proc:write(str)
  proc:close_stream(process.STREAM_STDIN)
  local res = {}
  local yieldTime=0.01
  while true do
    local rdbuf = proc:read_stdout()
    if not rdbuf then break end
    if #rdbuf > 0 then table.insert(res, rdbuf) end

    coroutine.yield(yieldTime)
    if yieldTime < 1 then
      yieldTime = yieldTime * 2
    end
  end

  if proc:returncode() == 127 then
    core.error("Command not found: %s", cmd)
  end

  res = table.concat(res)
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
        core.add_thread(function()
          dv.doc:replace(function(str)
            return exec_rw(cmd, str:find("%\n$"), str)
          end)
        end)
      end
    })
  end,
})
