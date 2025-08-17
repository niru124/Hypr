#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Correct way to get current directory of the script
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Helper function for user confirmation ---
confirm_action() {
    read -p "Do you want to install/run: $1? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0 # User confirmed yes
    else
        return 1 # User confirmed no
    fi
}

# --- Core Packages and Configuration ---
install_core_packages() {
    echo "--- Starting Core Packages and Configuration Installation ---"

    PACKAGE_FILE="$CURRENT_DIR/packages.txt"
    PACKAGE_FILE2="$CURRENT_DIR/packages2.txt"

    # Check if package files exist
    if [ ! -f "$PACKAGE_FILE" ]; then
        echo "Error: File '$PACKAGE_FILE' not found! Skipping core package installation."
        return 1
    fi

    if [ ! -f "$PACKAGE_FILE2" ]; then
        echo "Error: File '$PACKAGE_FILE2' not found! Skipping core package installation."
        return 1
    fi

    # System update
    echo "Updating system with pacman..."
    sudo pacman -Syu --noconfirm

    # Install packages via pacman
    echo "Installing packages from '$PACKAGE_FILE' using pacman..."
    xargs -a "$PACKAGE_FILE" sudo pacman -S --noconfirm --needed

    # Install packages via yay
    echo "Installing packages from '$PACKAGE_FILE2' using yay..."
    xargs -a "$PACKAGE_FILE2" yay -S --noconfirm --needed

    echo "All core packages processed."

    # Copy configuration files to ~/.config using rsync
    CONFIG_DIR="$CURRENT_DIR/Config/.config"
    if [ -d "$CONFIG_DIR" ] && [ "$(ls -A "$CONFIG_DIR")" ]; then
        echo "Copying configuration files from .config to ~/.config..."
        mkdir -p "$HOME/.config"
        rsync -avv --exclude='.*' "$CONFIG_DIR/" "$HOME/.config/" > /dev/null 2>&1 # Suppress verbose output
        echo "Configuration files copied."
    else
        echo "Warning: '$CONFIG_DIR' does not exist or is empty. Skipping configuration copy."
    fi

    # Copy scripts to ~/.local/share/bin using rsync
    BIN_DIR="$CURRENT_DIR/bin2"
    if [ -d "$BIN_DIR" ] && [ "$(ls -A "$BIN_DIR")" ]; then
        echo "Copying scripts to ~/.local/share/bin..."
        mkdir -p ~/.local/share/bin
        rsync -av --exclude='.*' "$BIN_DIR/" ~/.local/share/bin/ > /dev/null 2>&1 # Suppress verbose output
        echo "Scripts copied to ~/.local/share/bin."
    else
        echo "Warning: '$BIN_DIR' does not exist or is empty. Skipping script copy."
    fi

    # Make all .sh scripts executable in ~/.local/share/bin
    echo "Making scripts executable in ~/.local/share/bin..."
    chmod +x ~/.local/share/bin/*.sh || true # Use true to prevent script from exiting if no .sh files are found
    echo "Scripts made executable."

    # Install zoxide using the official install script
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    echo "zoxide installation complete."

    echo "--- Core Packages and Configuration Installation Complete ---"
}

# --- Non-Essential Packages ---
install_non_essential_packages() {
    echo "--- Starting Non-Essential Packages Installation ---"

    PACKAGE_FILE="$CURRENT_DIR/non-essential.txt"

    # Check if package file exists
    if [ ! -f "$PACKAGE_FILE" ]; then
        echo "Error: File '$PACKAGE_FILE' not found! Skipping non-essential package installation."
        return 1
    fi

    # Install packages via yay
    echo "Installing packages from '$PACKAGE_FILE' using yay..."
    xargs -a "$PACKAGE_FILE" yay -S --noconfirm --needed

    echo "--- Non-Essential Packages Installation Complete ---"
}

# --- Fonts Installation ---
install_fonts() {
    echo "--- Starting Font Installation ---"

    install_nerd_font() {
        local FONT_NAME="$1"
        local DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
        local FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

        echo "Installing ${FONT_NAME} Nerd Font..."

        # Create font directory
        mkdir -p "$FONT_DIR"

        # Download and unzip the font
        echo "Downloading ${FONT_NAME}..."
        curl -L -o "${FONT_NAME}.zip" "$DOWNLOAD_URL"

        echo "Extracting ${FONT_NAME}..."
        unzip -o "${FONT_NAME}.zip" -d "$FONT_DIR"

        # Clean up the zip file
        rm "${FONT_NAME}.zip"

        echo "${FONT_NAME} installed in ${FONT_DIR}"
    }

    install_custom_font() {
        local FONT_NAME="$1"
        local DOWNLOAD_URL="$2"
        local FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

        echo "Installing ${FONT_NAME} font..."

        # Create font directory
        mkdir -p "$FONT_DIR"

        # Download and unzip the font
        echo "Downloading ${FONT_NAME}..."
        curl -L -o "${FONT_NAME}.zip" "$DOWNLOAD_URL"

        echo "Extracting ${FONT_NAME}..."
        unzip -o "${FONT_NAME}.zip" -d "$FONT_DIR"

        # Clean up the zip file
        rm "${FONT_NAME}.zip"

        echo "${FONT_NAME} installed in ${FONT_DIR}"
    }

    # Install Nerd Fonts
    install_nerd_font "CaskaydiaCove"
    install_nerd_font "0xProto"
    install_nerd_font "JetBrainsMono"

    # Install custom fonts (PLACEHOLDER URLs - YOU MAY NEED TO FIND ACTUAL DIRECT DOWNLOAD LINKS)
    # These URLs are examples and might not work. You'll need to find direct .zip download links.
    install_custom_font "Abocat" "https://example.com/abocat.zip" # Placeholder URL
    install_custom_font "SteelfishOutline" "https://example.com/steelfishoutline.zip" # Placeholder URL
    install_custom_font "Mexcellent" "https://example.com/mexcellent.zip" # Placeholder URL

    # Update font cache once after all installations
    echo "Updating font cache..."
    fc-cache -fv

    echo "--- Font Installation Complete ---"
}

# --- GTK Theme Installation ---
install_gtk_theme() {
    echo "--- Starting GTK Theme Installation ---"

    # Install Catppuccin GTK Theme
    echo "Installing Catppuccin GTK Theme using yay..."
    yay -S --noconfirm --needed catppuccin-gtk-theme-lavender

    # Grant Flatpak access to local themes
    echo "Granting Flatpak access to ~/.local/share/themes..."
    sudo flatpak override --filesystem=$HOME/.local/share/themes

    echo "--- GTK Theme Installation Complete ---"
}

# --- Pyprland Installation ---
install_pyprland() {
    echo "--- Starting Pyprland Installation ---"

    # Set the target directory
    CONFIG_DIR="$HOME/.config/hypr"
    VENV_DIR="$CONFIG_DIR/myenv"

    # Create the config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    # Navigate to the config directory
    cd "$CONFIG_DIR" || { echo "Error: Could not navigate to $CONFIG_DIR"; return 1; }

    # Create a Python virtual environment
    echo "Creating Python virtual environment for Pyprland..."
    python3 -m venv myenv

    # Activate the virtual environment (for this script's context)
    source "$VENV_DIR/bin/activate"

    # Install pyprland
    echo "Installing pyprland..."
    pip install pyprland

    echo "Pyprland installed in virtual environment at: $VENV_DIR"
    echo "--- Pyprland Installation Complete ---"
}

# --- TUI Greet Configuration ---
configure_tui_greet() {
    echo "--- Starting TUI Greet Configuration ---"

    CONFIG_FILE="/etc/greetd/config.toml"
    NEW_COMMAND='command = "tuigreet --cmd Hyprland --time --remember --asterisks --greeting '\'' Welcome to Hyprland '\'' --theme '\''border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red'\'''

    # Check if run as root
    if [ "$(id -u)" -ne 0 ]; then
      echo "Warning: TUI Greet configuration requires root privileges. Please run this script with sudo or manually configure it."
      echo "Skipping TUI Greet configuration."
      return 1
    fi

    # Check if the config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
      echo "Error: Config file not found: $CONFIG_FILE. Skipping TUI Greet configuration."
      return 1
    fi

    echo "Updating 'command =' in $CONFIG_FILE..."
    sed -i "s|^command = .*|$NEW_COMMAND|" "$CONFIG_FILE"

    echo "--- TUI Greet Configuration Complete ---"
}

# --- AstroNvim Installation ---
install_astronvim() {
    echo "--- Starting AstroNvim Installation ---"

    ASTROVIM_SCRIPT="$CURRENT_DIR/astrovim_install(extra).sh"

    if [ ! -f "$ASTROVIM_SCRIPT" ]; then
        echo "Error: AstroNvim installation script not found at '$ASTROVIM_SCRIPT'. Skipping AstroNvim installation."
        return 1
    fi

    echo "Running AstroNvim installation script..."
    chmod +x "$ASTROVIM_SCRIPT"
    "$ASTROVIM_SCRIPT"

    echo "--- AstroNvim Installation Complete ---"
}

# --- Cursor Theme Installation ---
install_cursor_theme() {
    echo "--- Starting Cursor Theme Installation ---"

    CURSOR_THEME_SCRIPT="$CURRENT_DIR/cursortheme.sh"

    if [ ! -f "$CURSOR_THEME_SCRIPT" ]; then
        echo "Error: Cursor theme installation script not found at '$CURSOR_THEME_SCRIPT'. Skipping cursor theme installation."
        return 1
    fi

    echo "Running cursor theme installation script..."
    chmod +x "$CURSOR_THEME_SCRIPT"
    "$CURSOR_THEME_SCRIPT"

    echo "--- Cursor Theme Installation Complete ---"
}

# --- Main Script Logic ---
echo "Welcome to the HyDE Installation Script!"
echo "This script will guide you through installing various components for your Hyprland setup."
echo 

# Core Packages
if confirm_action "Core Packages (pacman/yay packages, config files, scripts, zoxide)"; then
    install_core_packages
    echo
fi

# Non-Essential Packages
if confirm_action "Non-Essential Packages (from non-essential.txt)"; then
    install_non_essential_packages
    echo
fi

# Fonts
if confirm_action "Nerd Fonts (CaskaydiaCove, 0xProto, JetBrainsMono) and Custom Fonts (Abocat, Steelfish Outline, Mexcellent)"; then
    install_fonts
    echo
fi

# GTK Theme
if confirm_action "Catppuccin GTK Theme and Flatpak access"; then
    install_gtk_theme
    echo
fi

# Pyprland
if confirm_action "Pyprland (in a Python virtual environment)"; then
    install_pyprland
    echo
fi

# TUI Greet Configuration
if confirm_action "TUI Greet Display Manager Configuration (requires sudo)"; then
    configure_tui_greet
    echo
fi

# AstroNvim
if confirm_action "AstroNvim (Neovim configuration)"; then
    install_astronvim
    echo
fi

# Cursor Theme
if confirm_action "Bibata Cursor Theme Installation and Configuration"; then
    install_cursor_theme
    echo
fi

echo "Installation script finished. Please review the output for any errors."
echo "You may need to log out and back in for some changes to take effect."