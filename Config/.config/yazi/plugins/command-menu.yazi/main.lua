--- @sync entry
return {
    entry = function()
        local hovered = cx.active.current.hovered
        local ext = "default"
        local filename = ""
        if hovered then
            filename = tostring(hovered.url)
            ext = (filename:match("%.([^%.]+)$") or ""):lower()
            if ext == "" then ext = "default" end
        end

        local cmds
        if ext == "pdf" then
            cmds = {
                { name = "Open with Zathura", cmd = "zathura", append_file = true, block = false },
                { name = "Open with Evince", cmd = "evince", append_file = true, block = false },
            }
        elseif ext == "png" or ext == "jpg" or ext == "jpeg" then
            cmds = {
                { name = "Open with feh", cmd = "feh", append_file = true, block = false },
                { name = "Open with nsxiv", cmd = "nsxiv", append_file = true, block = false },
            }
        elseif ext == "txt" then
            cmds = {
                { name = "Edit with nvim", cmd = "nvim", append_file = true, block = false },
                { name = "View with cat", cmd = "cat", append_file = true, block = true },
            }
        else
            cmds = {
                { name = "List files", cmd = "ls -la", append_file = false, block = true },
                { name = "Git status", cmd = "git status", append_file = false, block = true },
                { name = "Open editor", cmd = "nvim", append_file = true, block = false },
            }
        end

        local names = {}
        local cases = {}
        for _, c in ipairs(cmds) do
            table.insert(names, c.name)
            local full_cmd = c.cmd
            if c.append_file and filename ~= "" then
                full_cmd = full_cmd .. " " .. ya.quote(filename)
            end
            if c.block == false then
                full_cmd = full_cmd .. " &"
            end
            table.insert(cases, '"' .. c.name .. '") ' .. full_cmd .. ' ;;')
        end

        local fzf_cmd = 'selected=$(printf "' .. table.concat(names, '\\n') .. '" | fzf); case "$selected" in ' .. table.concat(cases, ' ') .. ' *) echo "No selection" ;; esac'

        ya.manager_emit("shell", {
            fzf_cmd,
            block = true,
            orphan = true,
            confirm = true,
        })
    end,
}