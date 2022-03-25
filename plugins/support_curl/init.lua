-- mod-version:3 --lite-xl 2.1

local core = require "core"
local config = require "core.config"
local common = require "core.common"

local has_cc, cc = core.try(require, "plugins.support_cc")
local native_curl = has_cc and cc.compile_plugin(
  "plugins.support_curl.native", { 
  srcs = { "native.c" },
  libs = { "curl" }
}) or require "plugins.support_curl.native"

local support_curl = common.merge({ 
  timeout = 1,
  verbose = false
}, config.plugins.support_curl)

-- Parse out a response body.
function support_curl.parse(response)
  return response
end

local agent = native_curl.new()

function support_curl.request(request, done, fail)
  return agent:request(common.merge({
    method = "GET",
    headers = { ["User-Agent"] = "lite-xl/2.1" },
    timeout = support_curl.timeout,
    verbose = support_curl.verbose,
    done = function(response) done(support_curl.parse(response)) end,
    fail = function(response, code) 
      if fail then 
        fail(support_curl.parse(response), code) 
      else 
        error("error making request (" .. code .. "): " .. tostring(response)) 
      end 
    end
  }, request))
end

core.add_thread(function()
  while true do
    local had_running = agent:step()
    coroutine.yield(had_running and 0.01 or 0.1)
  end
end)

return support_curl
