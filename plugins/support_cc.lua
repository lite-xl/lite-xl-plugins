-- mod-version:3 --lite-xl 2.1

local core = require "core"
local config = require "core.config"
local common = require "core.common"

local cc = common.merge({
  backend = "gcc"
}, config.plugins.support_cc)

local function run_cmd(cmd, options)
  local process = process.start(cmd, options)
  local stdout, stderr = "", ""
  while (process:running()) do
    local stdout_chunk, stderr_chunk = process:read_stdout(), process:read_stderr()
    if stdout_chunk ~= nil then stdout = stdout .. stdout_chunk end
    if stderr_chunk ~= nil then stderr = stderr .. stderr_chunk end
  end
  local stdout_chunk, stderr_chunk = process:read_stdout(), process:read_stderr()
  if stdout_chunk ~= nil then stdout = stdout .. stdout_chunk end
  if stderr_chunk ~= nil then stderr = stderr .. stderr_chunk end
  return process:returncode(), stdout, stderr
end

function cc.compile_plugin(target, options)
  local dynamic_suffix = PLATFORM == "Mac OS X" and 'lib' or (PLATFORM == "Windows" and 'dll' or 'so')
  local path = USERDIR .. PATHSEP .. target:gsub("%.", PATHSEP) .. "." .. dynamic_suffix
  local directory = common.dirname(path)
  if not options.srcs then error("Can't find srcs.") end
  local lib_info = system.get_file_info(path)
  local requires_compile = lib_info == nil
  if lib_info then
    for i,v in ipairs(options.srcs) do 
      local info = system.get_file_info(directory .. PATHSEP .. v)
      if info and info.modified > lib_info.modified then
        requires_compile = true
        break
      end
    end
  end
  if requires_compile then
    if cc.backend == "gcc" then
      local cmd = { "gcc", "-fPIC", "-shared", "-g", "-o", path, "-I" .. EXEDIR .. PATHSEP .. "resources" }
      for i,v in ipairs(options.srcs or {}) do table.insert(cmd, directory .. PATHSEP .. v) end
      for i,v in ipairs(options.libs or {}) do table.insert(cmd, "-l" .. v) end
      local status, stdout, stderr = run_cmd(cmd, { })
      if status ~= 0 then error("Error compiling " .. path .. ": " .. stderr) end
      core.log("Compiled " .. target .. " successfully.")
    end
  end
  return require(target)
end

return cc
