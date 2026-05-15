-- Picture-in-Picture
hl.window_rule({ name = "pip_tag", match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, tag = "+picture-in-picture" })
hl.window_rule({ name = "pip_float", match = { tag = "picture-in-picture" }, float = true })
hl.window_rule({ name = "pip_aspect", match = { tag = "picture-in-picture" }, keep_aspect_ratio = true })
hl.window_rule({ name = "pip_move", match = { tag = "picture-in-picture" }, move = {"73%", "72%"} })
hl.window_rule({ name = "pip_size", match = { tag = "picture-in-picture" }, size = {"25%", "25%"} })
hl.window_rule({ name = "pip_pin", match = { tag = "picture-in-picture" }, pin = true })

-- Opacity rules
hl.window_rule({ name = "librewolf_opacity", match = { class = "^librewolf$" }, opacity = "0.90 0.90 1" })
hl.window_rule({ name = "thunar_opacity", match = { class = "^thunar$" }, opacity = "0.90 0.90 1" })
hl.window_rule({ name = "qt5ct_opacity", match = { class = "^qt5ct$" }, opacity = "0.80 0.80 1" })
hl.window_rule({ name = "qt6ct_opacity", match = { class = "^qt6ct$" }, opacity = "0.80 0.80 1" })
hl.window_rule({ name = "pavucontrol_opacity", match = { class = "^org.pulseaudio.pavucontrol$" }, opacity = "0.80 0.70 1" })
hl.window_rule({ name = "blueman_opacity", match = { class = "^blueman-manager$" }, opacity = "0.80 0.70 1" })
hl.window_rule({ name = "nm_applet_opacity", match = { class = "^nm-applet$" }, opacity = "0.80 0.70 1" })
hl.window_rule({ name = "nm_editor_opacity", match = { class = "^nm-connection-editor$" }, opacity = "0.80 0.70 1" })
hl.window_rule({ name = "polkit_kde_opacity", match = { class = "^org.kde.polkit-kde-authentication-agent-1$" }, opacity = "0.80 0.70 1" })
hl.window_rule({ name = "polkit_gnome_opacity", match = { class = "^polkit-gnome-authentication-agent-1$" }, opacity = "0.80 0.70 1" })
hl.window_rule({ name = "portal_gtk_opacity", match = { class = "^org.freedesktop.impl.portal.desktop.gtk$" }, opacity = "0.80 0.70 1" })
hl.window_rule({ name = "portal_hyprland_opacity", match = { class = "^org.freedesktop.impl.portal.desktop.hyprland$" }, opacity = "0.80 0.70 1" })

-- Maximize
hl.window_rule({ name = "waydroid_maximize", match = { class = "^Waydroid$" }, maximize = true })

-- More opacity
hl.window_rule({ name = "boxes_opacity", match = { class = "^gnome-boxes$" }, opacity = "0.80 0.80" })
hl.window_rule({ name = "foot_opacity", match = { class = "^foot$" }, opacity = "0.80 0.80" })

-- Float rules
hl.window_rule({ name = "librewolf_profile", match = { title = "^LibreWolf - Choose User Profile$" }, float = true, center = true, size = {"monitor_w*0.20", "monitor_h*0.30"} })
hl.window_rule({ name = "volume_control", match = { title = "^Volume Control$" }, float = true, center = true, size = {"monitor_w*0.28", "monitor_h*0.38"} })
hl.window_rule({ name = "nsxiv", match = { class = "^Nsxiv$" }, float = true, center = true, size = {"monitor_w*0.45", "monitor_h*0.45"} })
hl.window_rule({ name = "nwg_displays", match = { class = "^nwg-displays$" }, float = true, center = true, size = {"monitor_w*0.75", "monitor_h*0.65"} })
hl.window_rule({ name = "feh", match = { class = "^feh$" }, float = true, center = true, size = {"monitor_w*0.35", "monitor_h*0.35"} })
hl.window_rule({ name = "blueman_float", match = { class = "^blueman-manager$" }, float = true, center = true, size = {"monitor_w*0.35", "monitor_h*0.35"} })
hl.window_rule({ name = "satty", match = { class = "^com.gabm.satty$" }, float = true, center = true, size = {"monitor_w*0.75", "monitor_h*0.65"} })
hl.window_rule({ name = "wifi_manager", match = { class = "^wifi-manager.py$" }, float = true, center = true, size = {"monitor_w*0.28", "monitor_h*0.45"}, move = {"1365", "39"} })
hl.window_rule({ name = "eog", match = { class = "^eog$" }, float = true })

-- Layer rules
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
