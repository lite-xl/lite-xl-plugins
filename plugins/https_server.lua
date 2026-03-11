-- mod-version:3
-- lightweight plugin to start/stop a temporary HTTPS server using Python's
-- built-in http.server and the system "openssl" command to generate a
-- self‑signed certificate.  The command runs in a background process so the
-- editor stays responsive.

local core = require "core"
local command = require "core.command"
local config = require "core.config"
local common = require "core.common"
local process = require "process"

-- default configuration values
-- port 4443 was chosen as a non‑standard HTTPS port that doesn't require
-- root privileges (443 is the well‑known HTTPS port, 4443 is just a common
-- convention for test servers).
config.plugins.https_server = common.merge({
  port = 4443,
  directory = nil,          -- nil means project_dir or current working dir
  cert = nil,               -- path to certificate file (key + cert)
  python = "python3",      -- interpreter used to launch server
  -- if "cmd" is set the plugin will execute that string via the shell
  -- instead of launching the bundled python script; this allows you to use
  -- a custom server (http2, caddy, `rust-http-server`, etc.) or write your
  -- own handler.  the string may contain "%p" or "%d" which will be
  -- expanded to the port and document directory respectively.
  cmd = nil,
}, config.plugins.https_server)

local server_proc

local function generate_cert(path)
  -- create a simple self-signed x509 certificate with openssl
  -- file contains both key and cert so we can pass it directly to python
  local cmd = string.format(
    "openssl req -x509 -newkey rsa:2048 -nodes -subj '/CN=localhost' -days 365 -keyout %s -out %s",
    path, path)
  os.execute(cmd)
end

local function start_server(port, dir, cert)
  if server_proc then
    core.error("HTTPS server is already running")
    return
  end
  port = port or config.plugins.https_server.port
  dir = dir or config.plugins.https_server.directory or core.project_dir or "."
  cert = cert or config.plugins.https_server.cert or
         (core.user_dir .. "/https-server.pem")

  -- make sure certificate file exists
  local f = io.open(cert, "r")
  if not f then
    generate_cert(cert)
  else
    f:close()
  end

-- choose the command to run; user may override via config.cmd
  local proc_args
  if config.plugins.https_server.cmd then
    -- perform basic placeholder expansion
    local cmdstr = config.plugins.https_server.cmd
      :gsub("%%p", tostring(port))
      :gsub("%%d", dir)
    proc_args = {"/bin/sh", "-c", cmdstr}
  else
    -- Python script to spin up the HTTPS server
    local script = string.format([[ 
import http.server, ssl, os
os.chdir(%q)
port=%d
httpd=http.server.HTTPServer(('0.0.0.0', port), http.server.SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket(httpd.socket, certfile=%q, server_side=True)
httpd.serve_forever()
]], dir, port, cert)

    -- write the script to a temporary file so we can launch it
    local tmp = os.tmpname() .. ".py"
    local f2 = io.open(tmp, "w")
    f2:write(script)
    f2:close()

    proc_args = {config.plugins.https_server.python, tmp}
  end

  server_proc = process.start(proc_args, {
    stdin = process.REDIRECT_DISCARD,
    stdout = process.REDIRECT_DISCARD,
    stderr = process.REDIRECT_PIPE
  })

  core.status_view:enter_text("HTTPS server running on https://localhost:" .. port)
end

local function stop_server()
  if not server_proc then
    core.error("HTTPS server is not running")
    return
  end
  server_proc:kill()
  server_proc = nil
  core.status_view:enter_text("HTTPS server stopped")
end

command.add(nil, {
  ["https_server:start"] = function()
    core.command_view:enter("Start HTTPS server (port)", {
      submit = function(str)
        local p = tonumber(str) or config.plugins.https_server.port
        start_server(p)
      end
    })
  end,

  ["https_server:stop"] = stop_server,
})

-- optional menu entry under the main menu bar; wait until core.menu exists
core.add_thread(function()
  while not core.menu do
    coroutine.yield(1)
  end
  table.insert(core.menu, { "HTTPS Server", {
    { text = "Start HTTPS server", command = "https_server:start" },
    { text = "Stop HTTPS server",  command = "https_server:stop" },
  }})
end)

-- shutdown hook to automatically kill the subprocess when the project quits
local on_quit_project = core.on_quit_project
function core.on_quit_project()
  stop_server()
  if on_quit_project then
    on_quit_project()
  end
end

-- keep an eye on the subprocess so we can clear the handle if it exits
core.add_thread(function()
  while true do
    coroutine.yield(1)
    if server_proc then
      local rc = server_proc:returncode()
      if rc then
        core.status_view:enter_text("HTTPS server exited (" .. rc .. ")")
        server_proc = nil
      end
    end
  end
end)

-- expose a simple API in case other plugins want to drive it
local M = {}
M.start = start_server
M.stop = stop_server
return M
