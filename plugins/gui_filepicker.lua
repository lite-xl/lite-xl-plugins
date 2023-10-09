-- mod-version:3

local core = require("core")
local command = require("core.command")
local common = require("core.common")
local keymap = require("core.keymap")

command.add(nil, {

	["gui-filepicker:open-file"] = function()
		local zen, proc_err = process.start({
			"zenity",
			"--file-selection",
		}, { stdout = process.REDIRECT_PIPE })
		if not zen then
			core.error("Unable to run zenity: %s", proc_err)
			return
		end

		-- Run this in a coroutine, so we don't block the UI
		core.add_thread(function()
			local buffer = {}
			while zen:running() do
				local buf = zen:read_stdout()
				if buf and #buf > 0 then
					table.insert(buffer, buf)
				end
				coroutine.yield()
			end
			local abs_path = table.concat(buffer) or ""

			-- Remove final newline zenity adds
			abs_path = string.match(abs_path, "^[^\n]+") or ""
			if #abs_path == 0 then
				return
			end
			core.root_view:open_doc(core.open_doc(common.home_expand(abs_path)))
		end)
	end,

	["gui-filepicker:open-project-folder"] = function()
		local zen, proc_err = process.start({
			"zenity",
			"--file-selection",
			"--directory",
		}, { stdout = process.REDIRECT_PIPE })
		if not zen then
			core.error("Unable to run zenity: %s", proc_err)
			return
		end

		-- Run this in a coroutine, so we don't block the UI
		core.add_thread(function()
			local buffer = {}
			while zen:running() do
				local buf = zen:read_stdout()
				if buf and #buf > 0 then
					table.insert(buffer, buf)
				end
				coroutine.yield()
			end
			local abs_path = table.concat(buffer) or ""

			-- Remove final newline zenity adds
			abs_path = string.match(abs_path, "^[^\n]+") or ""
			if #abs_path == 0 then
				return
			end

			if abs_path == core.project_dir then
				return
			end
			os.execute(string.format("%q %q", EXEFILE, abs_path))
		end)
	end,

	["gui-filepicker:change-project-folder"] = function()
		local zen, proc_err = process.start({
			"zenity",
			"--file-selection",
			"--directory",
		}, { stdout = process.REDIRECT_PIPE })
		if not zen then
			core.error("Unable to run zenity: %s", proc_err)
			return
		end

		-- Run this in a coroutine, so we don't block the UI
		core.add_thread(function()
			local buffer = {}
			while zen:running() do
				local buf = zen:read_stdout()
				if buf and #buf > 0 then
					table.insert(buffer, buf)
				end
				coroutine.yield()
			end
			local abs_path = table.concat(buffer) or ""

			-- Remove final newline zenity adds
			abs_path = string.match(abs_path, "^[^\n]+") or ""
			if #abs_path == 0 then
				return
			end

			if abs_path == core.project_dir then
				return
			end
			core.confirm_close_docs(core.docs, function(dirpath)
				core.open_folder_project(dirpath)
			end, abs_path)
		end)
	end,

	["gui-filepicker:add-directory"] = function()
		local zen, proc_err = process.start({
			"zenity",
			"--file-selection",
			"--directory",
		}, { stdout = process.REDIRECT_PIPE })
		if not zen then
			core.error("Unable to run zenity: %s", proc_err)
			return
		end

		-- Run this in a coroutine, so we don't block the UI
		core.add_thread(function()
			local buffer = {}
			while zen:running() do
				local buf = zen:read_stdout()
				if buf and #buf > 0 then
					table.insert(buffer, buf)
				end
				coroutine.yield()
			end
			local abs_path = table.concat(buffer) or ""

			-- Remove final newline zenity adds
			abs_path = string.match(abs_path, "^[^\n]+") or ""
			if #abs_path == 0 then
				return
			end

			if abs_path == core.project_dir then
				return
			end
			core.add_project_directory(system.absolute_path(abs_path))
		end)
	end,
})

command.add("core.docview", {

	["gui-filepicker:save-as"] = function(dv)
		local text
		text = text or "new_file"
		local doc = dv.doc
		if dv.doc.filename then
			text = dv.doc.filename
		end
		local zen, proc_err = process.start({
			"zenity",
			"--file-selection",
			"--save",
			"--filename",
			text,
		}, { stdout = process.REDIRECT_PIPE })
		if not zen then
			core.error("Unable to run zenity: %s", proc_err)
			return
		end

		-- Run this in a coroutine, so we don't block the UI
		core.add_thread(function()
			local buffer = {}
			while zen:running() do
				local buf = zen:read_stdout()
				if buf and #buf > 0 then
					table.insert(buffer, buf)
				end
				coroutine.yield()
			end
			local abs_path = table.concat(buffer) or ""

			-- Remove final newline zenity adds
			abs_path = string.match(abs_path, "^[^\n]+") or ""
			if #abs_path == 0 then
				return
			end
			doc:save(abs_path, abs_path)
			core.log('Saved as "%s"', dv.doc.filename)
		end)
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
