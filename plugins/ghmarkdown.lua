-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"


local html = [[
<html>
  <style>
    body {
      margin:80 auto 100 auto;
      max-width: 750px;
      line-height: 1.6;
      font-family: Open Sans, Arial;
      color: #444;
      padding: 0 10px;
    }
    h1, h2, h3 { line-height: 1.2; padding-top: 14px; }
    hr { border: 0px; border-top: 1px solid #ddd; }
    code, pre { background: #f3f3f3; padding: 8px; }
    code { padding: 4px; }
    a { text-decoration: none; color: #0366d6; }
    a:hover { text-decoration: underline; }
    table { border-collapse: collapse; }
    table, th, td { border: 1px solid #ddd; padding: 6px; }
  </style>
  <head>
    <title>${title}</title>
  <head>
  <body>
    <script>
      var xhr = new XMLHttpRequest;
      xhr.open("POST", "https://api.github.com/markdown/raw");
      xhr.setRequestHeader("Content-Type", "text/plain");
      xhr.onload = function() { document.body.innerHTML = xhr.responseText; };
      xhr.send("${content}");
    </script>
  </body>
</html>
]]


command.add("core.docview", {
  ["ghmarkdown:show-preview"] = function()
    local dv = core.active_view

    local content = dv.doc:get_text(1, 1, math.huge, math.huge)
    local esc = { ['"'] = '\\"', ["\n"] = '\\n' }
    local text = html:gsub("${(.-)}", {
      title = dv:get_name(),
      content = content:gsub(".", esc)
    })

    local htmlfile = core.temp_filename(".html")
    local fp = io.open(htmlfile, "w")
    fp:write(text)
    fp:close()

    core.log("Opening markdown preview for \"%s\"", dv:get_name())
    if PLATFORM == "Windows" then
      system.exec("start " .. htmlfile)
    else
      system.exec(string.format("xdg-open %q", htmlfile))
    end

    core.add_thread(function()
      coroutine.yield(5)
      os.remove(htmlfile)
    end)
  end
})


keymap.add { ["ctrl+shift+m"] = "ghmarkdown:show-preview" }
