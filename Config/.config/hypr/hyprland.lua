--     ░▒▒▒░░░░░▓▓          ___________
--    ░░▒▒▒░░░░░▓▓        //___________/
--   ░░▒▒▒░░░░░▓▓     _   _ _    _ _____
--   ░░▒▒░░░░░▓▓▓▓▓▓ | | | | |  | |  __/
--    ░▒▒░░░░▓▓   ▓▓ | |_| | |_/ /| |___
--     ░▒▒░░▓▓   ▓▓   \__  |____/ |____/
--       ░▒▓▓   ▓▓  //____/

local scrPath = os.getenv("HOME") .. "/.local/share/bin"
local mainMod = "SUPER"

-- Autostart applications
hl.on("hyprland.start", function()
  hl.exec_cmd(scrPath .. "/resetxdgportal.sh")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("waybar")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("dunst")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd(scrPath .. "/swwwallpaper.sh")
  hl.exec_cmd(scrPath .. "/batterynotify.sh")
  hl.exec_cmd("hyprsunset -t 2500K")
  hl.exec_cmd("pypr")
  hl.exec_cmd("hyprpm reload")
  hl.exec_cmd("smooth-scroll")
  hl.exec_cmd("hyprpm reload Hyprspace")
  hl.exec_cmd("hyprshader on")
  hl.exec_cmd("youtube-local")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("/usr/lib/xdg-desktop-portal")
  hl.exec_cmd("niri-screen-time -daemon")
  hl.exec_cmd("hyprdynamicmonitors prepare")
  hl.exec_cmd("hyprdynamicmonitors run")
  hl.exec_cmd(scrPath .. "/recent.sh")
end)

-- Environment variables
hl.env("PATH", os.getenv("PATH") .. ":" .. scrPath)
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("LANG", "en_US.UTF-8")
hl.env("LC_ALL", "en_US.UTF-8")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_SCALE", "1")

-- Input configuration
hl.config({
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
    },
    sensitivity = 1,
    force_no_accel = true,
    numlock_by_default = false,
  },
})

-- General configuration
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 4,
    border_size = 3,
    layout = "scrolling",
    ["col.active_border"] = {
      colors = {
        "rgba(155,122,194,1)",
        "rgba(189,154,230,1)",
        "rgba(40,12,62,1)",
        "rgba(209,170,240,1)",
        "rgba(155,122,194,1)",
        "rgba(189,154,230,1)",
        "rgba(40,12,62,1)",
        "rgba(209,170,240,1)",
      },
    },
    ["col.inactive_border"] = {
      colors = {
        "rgba(81,87,109,1)",
        "rgba(98,104,128,1)",
        "rgba(115,121,148,1)",
        "rgba(131,139,167,1)",
      },
      angle = 45,
    },
  },
})

-- Decoration configuration
hl.config({
  decoration = {
    rounding = 10,
    blur = {
      enabled = true,
      size = 12,
      passes = 4,
      ignore_opacity = false,
      new_optimizations = true,
      brightness = 1.0,
      contrast = 1.0,
      vibrancy = 0.8,
      vibrancy_darkness = 0.2,
    },
  },
})

-- Dwindle layout configuration
hl.config({
  dwindle = {
    preserve_split = true,
  },
})

-- Scrolling layout configuration
hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 0.5,
    focus_fit_method = 1,
    follow_focus = true,
    follow_min_visible = 0.4,
    explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
    wrap_focus = true,
    wrap_swapcol = true,
    direction = "right",
  },
})

-- Misc configuration
hl.config({
  misc = {
    vrr = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },
})

-- XWayland configuration
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})

-- Animations (disabled preset)
hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })
hl.curve("linear", { type = "bezier", points = { {1, 1}, {1, 1} } })

hl.animation({ leaf = "windows", enabled = false, speed = 3, curve = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = false, speed = 3, curve = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = false, speed = 3, curve = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = false, speed = 2, curve = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 7, bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })
hl.animation({ leaf = "fade", enabled = false, speed = 10, curve = "default" })
hl.animation({ leaf = "workspaces", enabled = false, speed = 5, curve = "wind" })
hl.animation({ leaf = "specialWorkspace", enabled = false, speed = 5, curve = "wind", style = "slidevert" })

-- Source additional configuration files
dofile(os.getenv("HOME") .. "/.config/hypr/keybindings.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/windowrules.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/monitors.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/nvidia.lua")

-- Keybindings are in keybindings.lua
