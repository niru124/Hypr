# HyDE Installation Guide

HyDE is a Hyprland Desktop Environment setup. This repository contains installation scripts to set up the environment.

## Installation Scripts

The main script `install_all.sh` runs components in the following order (based on user confirmation with y/n):

1. Core Packages (install_core.sh - installs pacman/yay packages, copies configs, scripts, installs zoxide)
2. Non-Essential Packages (install_non_essential.sh - installs from non-essential.txt)
3. Fonts (install_fonts.sh - installs Nerd and custom fonts)
4. GTK Theme (install_gtk_theme.sh - installs Catppuccin theme, grants Flatpak access)
5. Pyprland (pyprland.sh - sets up venv and installs pyprland)
6. TUI Greet Configuration (tui_greet.sh - updates greetd config, enables service if root)
7. AstroNvim (install_astronvim.sh - runs astrovim_install(extra).sh)
8. Cursor Theme (install_cursor_theme.sh - runs cursortheme.sh)
9. Non-Essential Packages (install_non_essential.sh - optional rerun)
10. Hyprpm Plugins (install_hyprpm_plugins.sh - optional)
11. Packages (install-packages.sh - optional)

## Usage

Run `./install_all.sh` and follow the prompts to install components selectively.