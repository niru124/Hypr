#!/bin/bash

echo "--- Starting GPU Driver Installation ---"

install_nvidia_drivers() {
    echo "Installing NVIDIA drivers..."
    sudo pacman -S --noconfirm --needed nvidia nvidia-utils
    echo "NVIDIA drivers installed."
}

install_amd_drivers() {
    echo "Installing AMD drivers..."
    sudo pacman -S --noconfirm --needed mesa xf86-video-amdgpu
    echo "AMD drivers installed."
}

install_intel_drivers() {
    echo "Installing Intel drivers..."
    sudo pacman -S --noconfirm --needed mesa xf86-video-intel
    echo "Intel drivers installed."
}

# Check for GPU and install appropriate drivers
if lspci | grep -qi "nvidia"; then
    install_nvidia_drivers
elif lspci | grep -qi "amd"; then
    install_amd_drivers
elif lspci | grep -qi "intel"; then
    install_intel_drivers
else
    echo "No dedicated GPU detected. Using Mesa defaults."
    sudo pacman -S --noconfirm --needed mesa
fi

echo "--- GPU Driver Installation Complete ---"
