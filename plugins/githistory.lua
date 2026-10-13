--mod-version:3

local core = require "core"
local command = require "core.command"
local common = require "core.common"
local config = require "core.config"

config.plugins.githistory = common.merge({
  default_branch = "HEAD",

  config_spec = {
    name = "Git History",
    {
      label = "Default Branch",
      description = "Default branch to use when none is specified. Default \"HEAD\" points to current branch. If the branch does not exist, a error will be logged.",
      path = "default_branch",
      type = "string",
      default = "HEAD"
    }
  }
}, config.plugins.githistory)

-- Excutes command and returns text output, derived from gitopen plugin
local function exec(cmd)
  local proc = process.start(cmd)
  while proc:running() do
    coroutine.yield(0.1)
  end
  if proc:returncode() > 0 then
    core.error("ERROR - command: " .. table.concat(cmd, " "))
  end
  return proc:read_stdout() or ""
end

-- Creates a document name representing a file at a specific Git commit denoted by the hash
local function git_document_name(commit, file, suffix)
  suffix = suffix or ""

  local filename = file:match("[^/\\]+$")
  local path = file:sub(1, #file - #filename)

  local short_commit = commit:sub(1, 7)

  return path .. "git:" .. short_commit .. ":" .. filename .. suffix
end

-- Returns a list of files part of commit given a commit hash
local function git_get_files(commit)
  local files = exec({"git", "show", "--name-only", "--pretty=format:", commit})

  local file_list = {}

  for file in files:gmatch("([^\n]+)") do
    table.insert(file_list, file)
  end

  return file_list
end

-- Returns a list of tables represeting commit details given a branch name
local function git_get_log(branch)
  local output = exec({"git", "log", "--first-parent", "--date=relative", "--pretty=format:%H%x09%h%x09%an%x09%ad%x09%s", branch})

  local commits = {}

  for line in output:gmatch("[^\n]+") do
    local hash, short_hash, author, date, subject = line:match("^(.-)\t(.-)\t(.-)\t(.-)\t(.*)$")

    if hash then
      table.insert(commits, {
        hash = hash,
        short_hash = short_hash,
        author = author,
        date = date,
        subject = subject,
      })
    end
  end

  return commits
end

-- Opens a document with the contents of the excuted command given the args and commit hash and file name for the document name, document is read only
local function display_file(commit, file, git_args, suffix)
  local content = exec(git_args)

  local doc = core.open_doc(git_document_name(commit, file, suffix))

  doc:clean()
  doc:insert(1, 1, content)

  doc.insert = function() end
  doc.remove = function() end
  doc.replace = function() end
  doc.indent_text = function() end
  doc.is_dirty = function() return false end

  core.root_view:open_doc(doc)
end


-- Prompts to select a file in a commit given a commit hash and a callback to handle on_select
local function select_file(commit, on_select)
  local files = git_get_files(commit)

  if #files == 0 then
    core.log('GitHistory: No files found in commit ' .. commit)
    return
  end

  core.command_view:enter("Which file?", {
    suggest = function(text)
      local suggestions = {}

      for index, file in ipairs(files) do
        if text == "" or file:lower():find(text:lower(), 1, true) then
          table.insert(suggestions, file)
        end
      end

      return suggestions
    end,

    submit = function(file)
      for index, existing_file in ipairs(files) do
        if existing_file == file then
          core.add_thread(
            function()
              on_select(file, commit)
            end
          )
          return
       end
      end

      core.log('GitHistory: File "' .. file .. '" not found in commit')
    end
  })
end

-- Display branch commit logs and prompts to select/type entry/commit given branch name and a callback to handle on_select
local function display_logs(branch, on_select)
  local logs = git_get_log(branch)

  if #logs == 0 then
    core.log("GitHistory: No commits found for branch " .. branch)
    return
  end
            
  core.command_view:enter("Commits in " .. branch .. ", select entry or type commit", {
    suggest = function(entry)
      local suggestions = {}

        for index, commit in ipairs(logs) do
          local text = commit.short_hash .. " | " .. commit.author .. " | " .. commit.date .. " | " .. commit.subject

          if entry == "" or text:lower():find(entry:lower(), 1, true) then
            table.insert(suggestions, text)
          end
        end

      return suggestions
    end,

    submit = function(selection)
      if selection == "" or selection == nil then
        core.log('GitHistory: No entry selected or no commit inputted')
      end
    
      local input = selection:match("^(%S+)")

      for index, commit in ipairs(logs) do
        if commit.short_hash == input or commit.hash == input or commit.hash:sub(1, #input) == input then
          core.add_thread(
            function()
              on_select(commit)
            end
          )
          return
        end
      end

      core.log("GitHistory: Commit \"" .. input .. "\" not found")
    end
  })
end

-- View a file state or file diff from a commit by inputting commit hash
command.add(nil, {
  ["githistory:view-file-from-commit"] = function()
    core.command_view:enter("Which commit?", {
      submit = function(commit)
        if commit == nil or commit == "" then
          core.log('GitHistory: No commit passed in')
          return
        end

        core.add_thread(
          function()
            select_file(commit, function(file, commit) display_file(commit, file, {"git", "show", commit .. ":" .. file}) end)
          end
        )
      end
    })
  end
})

command.add(nil, {
  ["githistory:view-file-diff-from-commit"] = function()
    core.command_view:enter("Which commit?", {
      submit = function(commit)
        if commit == nil or commit == "" then
          core.log('GitHistory: No commit passed in')
          return
        end

        core.add_thread(
          function()
            select_file(commit, function(file, commit) display_file(commit, file, {"git", "show", "--format=", "--patch", commit, "--", file}, ".diff") end)
          end
        )
      end
    })
  end
})

-- View commit timeline on a branch, making a selection on a commit in the timeline will log the commit detail to logs
command.add(nil, {
  ["githistory:view-commit-timeline"] = function()
    core.command_view:enter("Which branch? (default=" .. config.plugins.githistory.default_branch .. ")", {
      submit = function(branch)
        if branch == nil or branch == "" then
          branch = config.plugins.githistory.default_branch
        end

        core.add_thread(
          function()
            display_logs(branch, function(commit) core.log("GitHitory: Log commit detail - " .. commit.hash .. " | " .. commit.author .. " | " .. commit.date .. " | " .. commit.subject) end)
          end
        )
      end
    })
  end
})

-- View a file state or file diff from a commit by selecting a commit entry on the timeline, a commit hash can also be inputted
command.add(nil, {
  ["githistory:view-file-selecting-commit-from-timeline"] = function()
    core.command_view:enter("Which branch? (default=" .. config.plugins.githistory.default_branch .. ")", {
      submit = function(branch)
        if branch == nil or branch == "" then
          branch = config.plugins.githistory.default_branch
        end

        core.add_thread(
          function()
            display_logs(branch, function(commit)
              core.add_thread(
                function()
                  select_file(commit.hash, function(file, commit) display_file(commit, file, {"git", "show", commit .. ":" .. file}) end)
                end
              )
            end)
          end
        )
      end
    })
  end
})

command.add(nil, {
  ["githistory:view-file-diff-selecting-commit-from-timeline"] = function()
    core.command_view:enter("Which branch? (default=" .. config.plugins.githistory.default_branch .. ")", {
      submit = function(branch)
        if branch == nil or branch == "" then
          branch = config.plugins.githistory.default_branch
        end

        core.add_thread(
          function()
            display_logs(branch, function(commit)
              core.add_thread(
                function()
                  select_file(commit.hash, function(file, commit) display_file(commit, file, {"git", "show", "--format=", "--patch", commit, "--", file}, ".diff") end)
                end
              )
            end)
          end
        )
      end
    })
  end
})

