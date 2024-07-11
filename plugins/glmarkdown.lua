-- mod-version:3

-- GitLab Flavored Markdown Preview
-- This plugin generates a Markdown preview in your default browser using a temporary HTML file, which is converted through the GitLab Markdown API.

-- Prerequisites:
-- You need a GitLab access token to use the Markdown API. 
-- You can find the token on line 27, which GitLab API is used on Line 93. You can update both if needed.
-- For more information on GitLab API authentication, refer to the official documentation: https://docs.gitlab.com/ee/api/rest/#authentication

-- I personally use a personal access token with "read_api" rights.
-- You can find the GitLab Markdown API documentation here: https://docs.gitlab.com/ee/api/markdown.html

-- Optional feature:
-- You can add a project attribute to the API request if needed.

-- Important note:
-- Since this plugin uses the GitLab API, a connection to the API is required for the preview to work.

local core = require "core"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"
local keymap = require "core.keymap"

config.plugins.gitlabmarkdownprev = common.merge({
  gitlab_token = "",
  config_spec = {
    name = "GLMarkdown",
    {
      label = "GitLab token",
      description = "Enter your personal Gitlab token",
      path = "gitlab_token",
      type = "string",
      default = ""
    }
  }
}, config.plugins.gitlabmarkdownprev)

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
      xhr.open("POST", "${gitlab_api_url}/markdown");
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.setRequestHeader("PRIVATE-TOKEN", "${token}");
      xhr.onload = function() { 
          var response = JSON.parse(xhr.responseText);
      document.body.innerHTML = response.html; 
      };
      xhr.send(JSON.stringify({
          text: "${content}",
          gfm: true
      }));
    </script>
  </body>
</html>
]]

command.add("core.docview!", {
  ["gitlabmarkdownprev:show-preview"] = function(dv)
    local filename = dv.doc.filename
    if not filename or not filename:match("%.md$") then
      core.error("This command is only available for Markdown files (.md)")
      return
    end
    
    local content = dv.doc:get_text(1, 1, math.huge, math.huge)
    local esc = { ['"'] = '\\"', ["\n"] = '\\n' }
    local text = html:gsub("${(.-)}", {
      gitlab_api_url = "https://gitlab.com/api/v4",
      title = dv:get_name(),
      content = content:gsub(".", esc),
      token = config.plugins.gitlabmarkdownprev.gitlab_token
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
      coroutine.yield(10)
      os.remove(htmlfile)
    end)
  end
})

keymap.add { ["ctrl+alt+m"] = "gitlabmarkdownprev:show-preview" }
