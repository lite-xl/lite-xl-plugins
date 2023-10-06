-- mod-version:3

local core = require("core")
local command = require("core.command")
local common = require("core.common")
local keymap = require("core.keymap")

command.add(nil, {

	["zenity:open-file"] = function()
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

	["zenity:open-project-folder"] = function()
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

	["zenity:change-project-folder"] = function()
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

	["zenity:add-directory"] = function()
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

	["zenity:save-as"] = function(dv)
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
			core.log("Saved as " .. '"' .. dv.doc.filename  .. '"')
		end)
	end,

	["zenity:save"] = function(dv)
		local doc = dv.doc
		if dv.doc.filename then
			doc:save()
			core.log("Saved " .. '"' .. dv.doc.filename  .. '"')
		else
			command.perform("zenity:save-as")
		end
	end,
})

keymap.add({
	["ctrl+s"] = "zenity:save",
	["ctrl+shift+s"] = "zenity:save-as",
	["ctrl+shift+c"] = "zenity:change-project-folder",
	["ctrl+o"] = "zenity:open-file",
	["ctrl+shift+o"] = "zenity:open-project-folder",
})
