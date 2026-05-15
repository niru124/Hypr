-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
-- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█

local scrPath = os.getenv("HOME") .. "/.local/share/bin"
local mainMod = "SUPER"

-- Toggle special workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special(""))
-- App variables
local term = "kitty"
local editor = "nvim"
local file = "thunar"
local browser = "librewolf"

-- Scripts
hl.bind("CTRL + F6", hl.dsp.exec_cmd("/usr/local/bin/capHypr"))

-- Window/Session actions
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(scrPath .. "/dontkillsteam.sh"))
hl.bind("ALT + B", hl.dsp.window.close())
hl.bind(mainMod .. " + DELETE", hl.dsp.exit())
hl.bind("SUPER + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind("ALT + F11", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("swaylock"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(scrPath .. "/windowpin.sh"))
hl.bind(mainMod .. " + BACKSPACE", hl.dsp.exec_cmd(scrPath .. "/logoutlaunch.sh"))
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("killall waybar || (env reload_flag=1 " .. scrPath .. "/wbarconfgen.sh)"))
hl.bind("CTRL + F12", hl.dsp.exec_cmd("killall grimblast || textHypr.sh"))
hl.bind("CTRL + F11", hl.dsp.exec_cmd("cd ~/STT/ && /usr/bin/python3 ~/STT/record_gui"))

-- Application shortcuts
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(file))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd(scrPath .. "/sysmonlaunch.sh"))
hl.bind("ALT + O", hl.dsp.exec_cmd(scrPath .. "/pavucontrol.sh"))

-- Rofi menus
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofilaunch.sh d"))
hl.bind("ALT + W", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofilaunch.sh w"))
hl.bind(mainMod .. " + W", hl.dsp.layout("colresize +conf"))

-- Scrolling layout - column width presets
hl.bind(mainMod .. " + 1", hl.dsp.layout("colresize 0.333"))
hl.bind(mainMod .. " + 2", hl.dsp.layout("colresize 0.5"))
hl.bind(mainMod .. " + 3", hl.dsp.layout("colresize 0.667"))
hl.bind(mainMod .. " + 4", hl.dsp.layout("colresize 1.0"))

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofilaunch.sh f"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/emoji.sh"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/quickapps.sh"))
hl.bind(mainMod .. " + ALT + Y", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofi_todo.sh"))
hl.bind("ALT + S", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/shaders.sh"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/bin/toggle_layout.sh"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/calc.sh --rasi ~/.config/rofi/calc.rasi"))
hl.bind("ALT + T", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/timer.sh"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/dict/1.sh"))
hl.bind("ALT + Y", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofi_todo.sh"))
hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd("pkill -x rofi || rofi -show rofi-sound -modi \"rofi-sound:" .. scrPath .. "/sound-switcher.sh\" -theme ~/.config/rofi/audio.rasi"))

hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("gemi"))

-- Audio control
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o m"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -i m"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o d"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o i"), { repeating = true })

hl.bind("F8", hl.dsp.exec_cmd(scrPath .. "/hyprsunset.sh d 200"), { repeating = true })
hl.bind("F9", hl.dsp.exec_cmd(scrPath .. "/hyprsunset.sh i 200"), { repeating = true })

-- Media control
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Brightness control
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd(scrPath .. "/brightnesscontrol.sh d"), { repeating = true })
hl.bind("ALT + XF86MonBrightnessUp", hl.dsp.exec_cmd(scrPath .. "/brightnesscontrol.sh i"), { repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(scrPath .. "/brightnesscontrol.sh i -s"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scrPath .. "/brightnesscontrol.sh d -s"), { repeating = true })

-- Move between grouped windows
hl.bind(mainMod .. " + CTRL + H", hl.dsp.group.prev())
hl.bind(mainMod .. " + CTRL + L", hl.dsp.group.next())

-- Screenshot/Screencapture
hl.bind("PRINT", function() hl.dispatch(hl.dsp.exec_cmd("hyprshot -m output --raw | satty -f - -o ~/Pictures/Screenshots/$(date +%H_%M_%d_%m_%Y)_hyprshot.png")) end)
hl.bind("ALT + PRINT", function() hl.dispatch(hl.dsp.exec_cmd("hyprshot -m region --raw | satty -f - -o ~/Pictures/Screenshots/$(date +%H_%M_%d_%m_%Y)_hyprshot.png")) end)
hl.bind("CTRL + PRINT", function() hl.dispatch(hl.dsp.exec_cmd("hyprshot -m window --raw | satty -f - -o ~/Pictures/Screenshots/$(date +%H_%M_%d_%m_%Y)_hyprshot.png")) end)
hl.bind(mainMod .. " + PRINT", function() hl.dispatch(hl.dsp.exec_cmd("hyprshot -zm region --raw | satty -f - -o ~/Pictures/Screenshots/$(date +%H_%M_%d_%m_%Y)_hyprshot.png")) end)

-- Custom scripts
hl.bind(mainMod .. " + ALT + G", hl.dsp.exec_cmd(scrPath .. "/gamemode.sh"))
hl.bind("CTRL + F9", hl.dsp.exec_cmd(scrPath .. "/swwwallpaper.sh -n"))
hl.bind("CTRL + F10", hl.dsp.exec_cmd(scrPath .. "/swwwallpaper.sh -p"))
hl.bind(mainMod .. " + ALT + UP", hl.dsp.exec_cmd(scrPath .. "/wbarconfgen.sh n"))
hl.bind(mainMod .. " + ALT + DOWN", hl.dsp.exec_cmd(scrPath .. "/wbarconfgen.sh p"))
hl.bind(mainMod .. " + CTRL + F9", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/wallbashtoggle.sh -m"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofiselect.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/swwwallselect.sh"))
hl.bind("ALT + V", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/cliphist.sh c"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/cliphist.sh"))
hl.bind(mainMod .. " + SLASH", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/keybinds_hint.sh c"))
hl.bind(mainMod .. " + ALT + A", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/animations.sh"))
hl.bind(mainMod .. " + ALT + N", hl.dsp.exec_cmd(scrPath .. "/go_back.sh"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/pass.sh"))

-- Move/Change window focus
hl.bind("ALT + L", function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end)
hl.bind("ALT + H", function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end)
hl.bind("ALT + J", function() hl.dispatch(hl.dsp.focus({ direction = "u" })) end)
hl.bind("ALT + K", function() hl.dispatch(hl.dsp.focus({ direction = "d" })) end)
hl.bind("ALT + TAB", function() hl.dispatch(hl.dsp.focus({ direction = "d" })) end)

-- Workspace switching (Alt key)
for i = 1, 9 do
  hl.bind("ALT + " .. i, function() hl.dispatch(hl.dsp.focus({ workspace = i })) end)
end
hl.bind("ALT + 0", function() hl.dispatch(hl.dsp.focus({ workspace = 10 })) end)

-- Switch workspaces to a relative workspace
hl.bind("ALT + CTRL + RIGHT", function() hl.dispatch(hl.dsp.focus({ workspace = "r+1" })) end)
hl.bind("ALT + CTRL + LEFT", function() hl.dispatch(hl.dsp.focus({ workspace = "r-1" })) end)

-- Move to the first empty workspace
hl.bind("ALT + SHIFT + O", function() hl.dispatch(hl.dsp.focus({ workspace = "empty" })) end)

-- Resize windows
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + LEFT", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + UP", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + DOWN", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- Move focused window to a workspace
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Move focused window to a relative workspace
hl.bind(mainMod .. " + CTRL + ALT + RIGHT", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + LEFT", hl.dsp.window.move({ workspace = "r-1" }))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/Resize focused window (mouse binds)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- Move active window around current workspace
hl.bind(mainMod .. " + SHIFT + CTRL + LEFT", function()
  local w = hl.get_active_window()
  if w and w.floating then
    hl.dispatch(hl.dsp.window.move({ x = -30, y = 0, relative = true }))
  else
    hl.dispatch(hl.dsp.window.move({ direction = "l" }))
  end
end)
hl.bind(mainMod .. " + SHIFT + CTRL + RIGHT", function()
  local w = hl.get_active_window()
  if w and w.floating then
    hl.dispatch(hl.dsp.window.move({ x = 30, y = 0, relative = true }))
  else
    hl.dispatch(hl.dsp.window.move({ direction = "r" }))
  end
end)
hl.bind(mainMod .. " + SHIFT + CTRL + UP", function()
  local w = hl.get_active_window()
  if w and w.floating then
    hl.dispatch(hl.dsp.window.move({ x = 0, y = -30, relative = true }))
  else
    hl.dispatch(hl.dsp.window.move({ direction = "u" }))
  end
end)
hl.bind(mainMod .. " + SHIFT + CTRL + DOWN", function()
  local w = hl.get_active_window()
  if w and w.floating then
    hl.dispatch(hl.dsp.window.move({ x = 0, y = 30, relative = true }))
  else
    hl.dispatch(hl.dsp.window.move({ direction = "d" }))
  end
end)



-- Suspend
hl.bind("ALT + D", hl.dsp.exec_cmd("systemctl suspend && hyprlock && hyprctl reload"))
-- Toggle focused window split
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("hyprlock && systemctl suspend && hyprctl reload"), { locked = true })

-- Move focused window to a workspace silently
hl.bind(mainMod .. " + ALT + 1", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 1"))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 2"))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 3"))
hl.bind(mainMod .. " + ALT + 4", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 4"))
hl.bind(mainMod .. " + ALT + 5", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 5"))
hl.bind(mainMod .. " + ALT + 6", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 6"))
hl.bind(mainMod .. " + ALT + 7", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 7"))
hl.bind(mainMod .. " + ALT + 8", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 8"))
hl.bind(mainMod .. " + ALT + 9", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 9"))
hl.bind(mainMod .. " + ALT + 0", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent 10"))

-- Pyprland
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("pypr toggle term"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("pypr toggle ranger"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("pypr toggle nvim"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("pypr layout_center toggle"))
hl.bind(mainMod .. " + LEFT", hl.dsp.exec_cmd("pypr layout_center prev"))
hl.bind(mainMod .. " + RIGHT", hl.dsp.exec_cmd("pypr layout_center next"))
hl.bind(mainMod .. " + UP", hl.dsp.exec_cmd("pypr layout_center prev2"))
hl.bind(mainMod .. " + DOWN", hl.dsp.exec_cmd("pypr layout_center next2"))

-- Overview plugin
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("plugin:overview:toggle"))
