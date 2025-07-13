Here's how we can **finalize and polish** your `README.md`-style documentation for **HyDE** and make it **clean, installation-friendly, and developer-ready** — especially since you've bundled Pyprland, dynamic theming, and modularity.

---

## HyDE - A Dynamic Hyprland Environment

**HyDE** is a comprehensive, intelligent, and highly dynamic configuration for the Hyprland Wayland compositor. It aims to provide a feature-rich, aesthetically pleasing, and deeply integrated desktop experience by automating theming, component configuration, and user feedback.

Built around modular and powerful shell scripts, **HyDE** manages everything from the status bar to window borders, creating a seamless, cohesive environment.

---

## ✨ Features

- **Dynamic Theming**
  Window borders and other UI elements adapt to your wallpaper's color palette using tools `ImageMagick` or custom logic.

- **Modular & Switchable Waybar**
  Easily switch between multiple Waybar layouts on the fly. Configurations and modules are dynamically generated.

- **Interactive Keybinding Helper**
  A searchable, Rofi-based cheat sheet for your keybindings — automatically generated from your Hyprland config.

- **Custom Login Manager**
  Includes a themed `tuigreet` setup that blends beautifully with your overall environment.

- **Pre-configured Applications**
  Comes bundled with tuned configs for:

  - **Neovim** (Arduino-ready)
  - **Yazi**
  - **Cava**
  - **Kitty**
  - **Hyprsunset**
  - And more...

- **Pyprland Plugin Support**
  Pre-installed and configured with:

- `scratchpad` (Yazi, floating terminal, Cava)
- `center` layout for better small-screen usage
- Extend easily via `~/.config/hypr/myenv/pyprland.toml`

---

## Installation

> Ensure that `git` are already installed before starting.
> or install using `sudo pacman -S git`

Clone the repo and run the installer:

```bash
git clone https://github.com/niru124/Hypr.git
cd HyDE/
chmod +x install-packages.sh
./install-packages.sh
```

This script will:

- Update your system
- Install required packages (Pacman + AUR)
- Copy configuration files to `~/.config`
- Install Pyprland in a virtual environment
- Setup scripts in `~/.local/share/bin`
- Run theme and font scripts
- Configure `tuigreet`, Waybar, and other components
- add or remove packages from `packages(pacman)` and `packages2(yay)`

---

## Directory Structure

```bash
HyDE/
├── install-packages.sh     # Main installation script
├── packages.txt            # Pacman packages
├── packages2.txt           # AUR (yay) packages
├── Config/
│   └── .config/            # All Hyprland-related dotfiles
├── bin2/                   # Custom helper scripts
├── pyprland.sh             # Pyprland setup script
├── gtk_theme.sh            # GTK theming
├── font.sh                 # Font installer
└── tui_greet.sh            # Login screen setup
```

---

## ⚙️ Extend Pyprland Plugins

To add more plugins, edit:

```bash
~/.config/hypr/myenv/pyprland.toml
```

other plugins and configurations could be found at https://hyprland-community.github.io/pyprland/Plugins.html

---

## Summary

- This environment is tailored for **power users**, but easy enough for beginners to explore.
- Most of the configuration is commented and self-documented.
- Additional instructions for customizing keybindings, layouts, and plugin behavior can be found inside the respective `.config` directories.
