local core = require "core"

local last_project_filename = EXEDIR .. PATHSEP .. ".lite_last_project"


-- load last project path
local fp = io.open(last_project_filename)
local project_path
if fp then
    project_path = fp:read("*a")
    fp:close()
end


-- save current project path
local fp = io.open(last_project_filename, "w")
if nil ~= fp then
    fp:write(system.absolute_path ".")
    fp:close()
end


-- restart using last project path if we had no commandline arguments and could
-- find a last-project file
if #ARGS == 1 and project_path then
    system.exec(string.format("%s %q", EXEFILE, project_path))
    core.quit(true)
end

