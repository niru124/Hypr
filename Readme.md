# HyDE - A Dynamic Hyprland Environment

**HyDE** is a comprehensive and highly dynamic configuration for the Hyprland Wayland compositor. It aims to provide a feature-rich, aesthetically pleasing, and deeply integrated desktop experience by automating theming, component configuration, and user feedback.

It's built around a collection of powerful shell scripts that manage everything from the status bar to window borders, making the environment feel cohesive and intelligent.

## ✨ Features
-   **Dynamic Theming**: Window borders and other UI elements can automatically adapt to your wallpaper's color scheme.
-   **Modular & Switchable Waybar**: Easily switch between multiple Waybar layouts and configurations on the fly. The bar's appearance and modules are generated dynamically.
-   **Interactive Keybinding Helper**: A Rofi-based, searchable cheat sheet for all your keybindings, generated directly from your Hyprland configuration files.
-   **Intelligent Battery Notifications**: A sophisticated notification system that alerts you at critical, low, and full battery levels, with configurable actions and timers.
-   **Integrated Media Controls**: A Waybar module that displays the currently playing media from various players like Spotify, with playback status icons.
-   **Custom Login Manager**: A themed `tuigreet` login manager for a consistent look from boot to desktop.
-   **Pre-configured Applications**: Includes curated configurations for tools like Neovim (with a full Arduino development setup) and the Yazi file manager.

Here’s a polished version of your **Installation** section:

---

## Installation

Run the following command to install the Hyprland configuration and move the necessary directories and files to their appropriate locations:

```bash
cd HyDE/
chmod +x install-packages.sh
./install-packages.sh
```

