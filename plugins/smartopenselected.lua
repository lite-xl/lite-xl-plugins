-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require "core.common"
local contextmenu = require "plugins.contextmenu"


command.add("core.docview!", {
  ["smart-open-selected:smart-open-selected"] = function(dv)
    local doc = dv.doc
    if not doc:has_selection() then
      core.error("No text selected")
      return
    end

    local text_orig = doc:get_text(doc:get_selection())
    text_orig = text_orig:match( "^%s*(.-)%s*$" )
    
    -- transform java/python imports to paths
    local text_path, num = text_orig:gsub("[.]", PATHSEP)
    
    -- keep the last . in case the path contains a file extension
    local text_keep_extension, num = text_orig:gsub("[.]", PATHSEP, num - 1)

    -- trim whitespace from the ends

    for dir, item in core.get_project_files() do
      if item.type == "file" and (
         string.find(item.filename, text_orig)
         or string.find(item.filename, text_path)
         or string.find(item.filename, text_keep_extension)
      ) then
        local path = (dir == core.project_dir and "" or dir .. PATHSEP)
        local filepath = common.home_encode(path .. item.filename)
        core.root_view:open_doc(core.open_doc(common.home_expand(filepath)))
      end
    end
  end,
})


contextmenu:register("core.docview", {
  { text = "Smart Open Selection",  command = "smart-open-selected:smart-open-selected" }
})


keymap.add { ["ctrl+shift+alt+p"] = "smart-open-selected:smart-open-selected" }
