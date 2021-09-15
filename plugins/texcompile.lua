-- mod-version:2 -- lite-xl 2.0
local core = require "core"
local config = require "core.config"
local command = require "core.command"
local common = require "core.common"
local keymap = require "core.keymap"

-- This code use an adaptation of the rxi/console plugin code to
-- start commands.

local pending_threads = {}
local thread_active = false

local function push_output(str, opt)
  -- By default we just ignore the output of a command.
  -- print(">>OUTPUT:", str)
end

local function read_file(filename, offset)
  local fp = io.open(filename, "rb")
  fp:seek("set", offset or 0)
  local res = fp:read("*a")
  fp:close()
  return res
end

local function write_file(filename, text)
  local fp = io.open(filename, "w")
  fp:write(text)
  fp:close()
end

local function init_opt(opt)
  local res = {
    command = "",
    arguments = {},
    on_complete = function() end,
  }
  for k, v in pairs(res) do
    res[k] = opt[k] or v
  end
  return res
end

local files = {
  script   = core.temp_filename(PLATFORM == "Windows" and ".bat"),
  script2  = core.temp_filename(PLATFORM == "Windows" and ".bat"),
  output   = core.temp_filename(),
  complete = core.temp_filename(),
}

local function command_run(opt)
  opt = init_opt(opt)

  local function thread()
    -- init script file(s)
    local args_quoted = {}
    for i, arg in ipairs(opt.arguments) do args_quoted[i] = string.format("%q", arg) end
    local args_concat = table.concat(args_quoted, " ")
    local working_dir = opt.working_dir or "."
    if PLATFORM == "Windows" then
      write_file(files.script, string.format("%s %s\n", opt.command, args_concat))
      write_file(files.script2, string.format([[
        @echo off
        cd %q
        call %q >%q 2>&1
        echo "" >%q
        exit
      ]], working_dir, files.script, files.output, files.complete))
      system.exec(string.format("call %q", files.script2))
    else
      write_file(files.script, string.format([[
        cd %q
        %s %s
        touch %q
      ]], working_dir, opt.command, args_concat, files.complete))
      system.exec(string.format("bash %q >%q 2>&1", files.script, files.output))
    end

    -- checks output file for change and reads
    local last_size = 0
    local function check_output_file()
      if PLATFORM == "Windows" then
        local fp = io.open(files.output)
        if fp then fp:close() end
      end
      local info = system.get_file_info(files.output)
      if info and info.size > last_size then
        local text = read_file(files.output, last_size)
        push_output(text, opt)
        last_size = info.size
      end
    end

    -- read output file until we get a file indicating completion
    while not system.get_file_info(files.complete) do
      check_output_file()
      coroutine.yield(0.1)
    end
    check_output_file()

    -- clean up and finish
    for _, file in pairs(files) do
      os.remove(file)
    end
    opt.on_complete()

    -- handle pending thread
    local pending = table.remove(pending_threads, 1)
    if pending then
      core.add_thread(pending)
    else
      thread_active = false
    end
  end

  -- push/init thread
  if thread_active then
    table.insert(pending_threads, thread)
  else
    core.add_thread(thread)
    thread_active = true
  end
end

command.add("core.docview", {
  ["texcompile:tex-compile"] = function()
    local av = core.active_view

    -- The current (La)TeX file and path
    local texname = av:get_name()
    local texpath = common.dirname(av:get_filename())

    -- Add in your user's config file something like:
    --
    -- config.texcompile = {
    --   latex_command = "pdflatex",
    --   view_command = "evince",
    -- }
    --
    -- On windows you may use the full path for the command like:
    --
    -- latex_command = [[c:\miktex\miktex\bin\x64\pdflatex.exe]],

    -- LaTeX compiler - is there any provided by the environment
    local texcmd = config.texcompile and config.texcompile.latex_command
    local viewcmd = config.texcompile and config.texcompile.view_command

    if not texcmd then
        core.log("No LaTeX compiler found")
    else
        core.log("LaTeX compiler is %s, compiling %s", texcmd, texname)

        command_run {
          command = texcmd,
          arguments = { texname },
          working_dir = texpath,
          on_complete = function() core.log("Tex compiling command terminated.") end
        }

        local pdfname = texname:gsub("%.tex$", ".pdf")
        command_run {
          command = viewcmd,
          arguments = { pdfname },
          working_dir = texpath
        }
    end
  end
})

keymap.add { ["ctrl+shift+t"] = "texcompile:tex-compile" }
