-- Auto-converted from animations-disabled.conf
-- See https://wiki.hyprland.org/Configuring/Animations/
-- -----------------------------------------------------
-- ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
-- █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█
--
-- name "Disabled"
-- credit https://github.com/mylinuxforwork/dotfiles
-- -----------------------------------------------------
hl.curve("wind", { type = "bezier", points = {{0.05, 0.9}, {0.1, 1.05}} })
hl.curve("winIn", { type = "bezier", points = {{0.1, 1.1}, {0.1, 1.1}} })
hl.curve("winOut", { type = "bezier", points = {{0.3, -0.3}, {0, 1}} })
hl.curve("liner", { type = "bezier", points = {{1, 1}, {1, 1}} })
hl.curve("linear", { type = "bezier", points = {{1, 1}, {1, 1}} })
-- Disable window animations by setting the second parameter (enabled) to 0
hl.animation({ leaf = "windows", enabled = false, speed = 3, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = false, speed = 3, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = false, speed = 3, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = false, speed = 2, bezier = "wind", style = "slide" })
-- These border animations will remain enabled as their second parameter is 1
hl.animation({ leaf = "border", enabled = true, speed = 7, bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })
-- Other animations (fade, workspaces, specialWorkspace) will also remain enabled
-- as their second parameter is 1. If you want to disable them, set their 2nd param to 0 as well.
hl.animation({ leaf = "fade", enabled = false, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = false, speed = 5, bezier = "wind" })
hl.animation({ leaf = "specialWorkspace", enabled = false, speed = 5, bezier = "wind", style = "slidevert" })

