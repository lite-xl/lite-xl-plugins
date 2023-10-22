-- mod-version:3

local core = require("core")
local command = require("core.command")
local common = require("core.common")
local keymap = require("core.keymap")
local TreeView = require("plugins.treeview")

local function run_zenity(options, callback)
	local zen, proc_err = process.start({
		"zenity",
		table.unpack(options)
	})
	if not zen then
		core.error("Unable to run zenity: %s", proc_err)
		return
	end

	-- Run this in a coroutine, so we don't block the UI
	core.add_thread(function()
		local buffer = {}
		repeat
			local buf = zen:read_stdout()
			if buf and #buf > 0 then
				table.insert(buffer, buf)
			end
			coroutine.yield()
		until not buf
		local abs_path = table.concat(buffer) or ""

		-- Remove final newline zenity adds
		abs_path = string.match(abs_path, "^[^\n]+") or ""
		if #abs_path == 0 then
			return
		end

		callback(abs_path)
	end)
end

command.add(nil, {
	["gui-filepicker:open-file"] = function()
		run_zenity(
			{
				"--file-selection"
			},
			function(abs_path)
				core.root_view:open_doc(core.open_doc(common.home_expand(abs_path)))
			end
		)
	end,

	["gui-filepicker:open-project-folder"] = function()
		run_zenity(
			{
				"--file-selection",
				"--directory",
			},
			function(abs_path)
				if abs_path == core.project_dir then
					return
				end
				os.execute(string.format("%q %q", EXEFILE, abs_path))
			end
		)
	end,

	["gui-filepicker:change-project-folder"] = function()
		run_zenity(
			{
				"--file-selection",
				"--directory",
			},
			function(abs_path)
				if abs_path == core.project_dir then
					return
				end
				core.confirm_close_docs(core.docs, function(dirpath)
					core.open_folder_project(dirpath)
				end, abs_path)
			end
		)
	end,

	["gui-filepicker:add-directory"] = function()
		run_zenity(
			{
				"--file-selection",
				"--directory",
			},
			function(abs_path)
				if abs_path == core.project_dir then
					return
				end
				core.add_project_directory(system.absolute_path(abs_path))
			end
		)
	end,
})

command.add("core.docview", {
	["gui-filepicker:save-as"] = function(dv)
		run_zenity(
			{
				"--file-selection",
				"--save",
				"--filename",
				dv.doc.filename or "new_file",
			},
			function(abs_path)
				dv.doc:save(abs_path, abs_path)
				core.log('Saved as "%s"', dv.doc.filename)
			end
		)
	end,

	["gui-filepicker:save"] = function(dv)
		if dv.doc.filename then
			command.perform("doc:save")
		else
			command.perform("gui-filepicker:save-as")
		end
	end,
})

keymap.add({
	["ctrl+s"] = "gui-filepicker:save",
	["ctrl+shift+s"] = "gui-filepicker:save-as",
	["ctrl+shift+c"] = "gui-filepicker:change-project-folder",
	["ctrl+o"] = "gui-filepicker:open-file",
	["ctrl+shift+o"] = "gui-filepicker:open-project-folder",
})

local replacements = {
	["core:open-file"] = "gui-filepicker:open-file",
	["doc:save"] = "gui-filepicker:save",
}
for _, v in ipairs(TreeView.toolbar.toolbar_commands) do
	if replacements[v.command] then
		v.command = replacements[v.command]
	end
end

