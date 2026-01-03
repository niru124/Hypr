-- Config for command-menu plugin
-- Add commands for different file extensions or default
return {
	-- Commands for PDF files
	pdf = {
		{ name = "Open with Zathura", cmd = "zathura" },
		{ name = "Open with Evince", cmd = "evince" },
	},
	-- Commands for text files
	txt = {
		{ name = "Edit with nvim", cmd = "nvim" },
		{ name = "View with cat", cmd = "cat" },
	},
	png = {
		{ name = "Open with feh", cmd = "feh" },
		{ name = "Open with nsxiv", cmd = "nsxiv" },
	},
	-- Default commands for other files or no file
	default = {
		{ name = "List files", cmd = "ls -la" },
		{ name = "Git status", cmd = "git status" },
		{ name = "Open editor", cmd = "nvim" },
		{ name = "Zip file", cmd = "$(zip_hovered.sh)" },
		{ name = "Zip files", cmd = "${zip_selected.sh}" },
	},
}
