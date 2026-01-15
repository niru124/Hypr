# fzf-command-menu

A Yazi plugin that provides an fzf-based menu for running custom commands on files and directories.

## Features

- **Fuzzy selection**: Uses fzf to provide a nice selection interface
- **File-type aware**: Commands are filtered based on file MIME types and extensions
- **Multi-file support**: Works with both selected files and hovered file
- **Directory support**: Special commands for directory operations
- **Flexible commands**: Commands can run on single/multiple files or pass input via stdin

## Usage

Press `M` (Shift+m) in Yazi to open the command menu. Select a command with fzf and press Enter.

## Keybindings

- `M` - Open the fzf command menu

## Commands

The plugin includes commands for:

- **Images**: nsxiv, feh, sxiv, wallpaper setting, WebP conversion, image resizing/rotating
- **PDFs**: zathura, evince
- **Video/Audio**: mpv playback, FFmpeg conversions
- **Text/Code**: nvim, nano, cat, less, syntax checking
- **File operations**: copy path/basename, file info, hex dump, checksums
- **Archives**: extract, zip, tar.gz, 7z compression
- **Git**: add, status, diff, log, commit
- **System**: ls, tree, chmod, rename, delete
- **Directories**: list, tree, grep, find

## Customization

Edit `init.lua` to modify or add commands. Each command is a table with:

```lua
{ name = "Display name", cmd = "command", for_mime = "type/*" }
{ name = "Display name", cmd = "command", for_ext = "ext" }
{ name = "Display name", cmd = "command", for_all = true }
{ name = "Display name", cmd = "command", for_dir = true }
{ name = "Display name", cmd = "command", passthrough = true }
```

- `for_mime`: Match by MIME type (e.g., "image/*", "video/*")
- `for_ext`: Match by file extension (string or table)
- `for_all`: Match any file
- `for_dir`: Match directories
- `passthrough`: Pass file paths via stdin
- `block`: Run in blocking mode

## Requirements

- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- Various command-line tools depending on which commands you use

## Troubleshooting

If fzf doesn't appear:
1. Make sure fzf is installed (`which fzf`)
2. Check Yazi notifications for errors
3. Try running in a terminal to see error output

## License

MIT
