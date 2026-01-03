--- @sync entry
return {
    entry = function()
        local hovered = cx.active.current.hovered
        local is_dir = ya.sync(function() local h = cx.active.current.hovered return h and h.cha.size() == nil end)
        local selected = cx.active.selected
        local selected_count = #selected
        local ext = "default"
        local filename = ""
        if hovered then
            filename = tostring(hovered.url)
            ext = (filename:match("%.([^%.]+)$") or ""):lower()
            if ext == "" then ext = "default" end
        end

		local cmds = {
			{ name = "List files", cmd = "ls -la", append_file = false, block = true },
			{ name = "Git status", cmd = "git status", append_file = false, block = true },
			{ name = "Open editor", cmd = "nvim", append_file = true, block = false },
		}

		if selected_count > 0 then
			table.insert(cmds, { name = "Zip selected files", cmd = "zip", append_file = false, block = true })
		else
			table.insert(cmds, { name = "Zip file", cmd = "zip", append_file = false, block = true })
		end

		if ext == "pdf" then
			table.insert(cmds, { name = "Open with Zathura", cmd = "zathura", append_file = true, block = false })
			table.insert(cmds, { name = "Open with Evince", cmd = "evince", append_file = true, block = false })
		elseif ext == "png" or ext == "jpg" or ext == "jpeg" then
			table.insert(cmds, { name = "Open with feh", cmd = "feh", append_file = true, block = false })
			table.insert(cmds, { name = "Open with nsxiv", cmd = "nsxiv", append_file = true, block = false })
		elseif ext == "txt" then
			table.insert(cmds, { name = "Edit with nvim", cmd = "nvim", append_file = true, block = false })
			table.insert(cmds, { name = "View with cat", cmd = "cat", append_file = true, block = true })
		end

		local names = {}
		local cases = {}
		for _, c in ipairs(cmds) do
			table.insert(names, c.name)
			local full_cmd = c.cmd
			if c.append_file and filename ~= "" then
				full_cmd = full_cmd .. " " .. ya.quote(filename)
			end
			if c.name == "Zip file" and filename ~= "" then
				local zip_name = filename:gsub("%.%w+$", ".zip")
				if is_dir then
					full_cmd = "zip -r -j " .. ya.quote(zip_name) .. " " .. ya.quote(filename)
				else
					full_cmd = "zip " .. ya.quote(zip_name) .. " " .. ya.quote(filename)
				end
			elseif c.name == "Zip selected files" then
				local date = os.date("%Y%m%d")
				local zip_name = "selected_" .. date .. ".zip"
				local quoted = {}
				for _, u in pairs(selected) do
					table.insert(quoted, ya.quote(tostring(u)))
				end
				full_cmd = "zip " .. ya.quote(zip_name) .. " " .. table.concat(quoted, " ")
			end
			if c.block == false then
				full_cmd = full_cmd .. " &"
			end
			table.insert(cases, '"' .. c.name .. '") ' .. full_cmd .. " ;;")
		end

		local fzf_cmd = 'selected=$(printf "'
			.. table.concat(names, "\\n")
			.. '" | fzf); case "$selected" in '
			.. table.concat(cases, " ")
			.. ' *) echo "No selection" ;; esac'

		ya.manager_emit("shell", {
			fzf_cmd,
			block = true,
			orphan = true,
			confirm = true,
		})
	end,
}
