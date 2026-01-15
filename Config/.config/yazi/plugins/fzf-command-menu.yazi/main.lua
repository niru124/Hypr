-- fzf-command-menu.yazi
ya.emit("shell", { cmd = "echo 'plugin initializing'", confirm = true })

local M = {}

function M.entry(_, job)
	ya.emit("shell", { cmd = "echo 'entry called'", confirm = true })
end

return { entry = M.entry }
