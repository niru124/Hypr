#!/bin/bash

set -e

echo "--- Installing Oh My Zsh and Dependencies ---"

# Install zsh if not present
if ! command -v zsh &>/dev/null; then
	echo "Installing zsh..."
	sudo pacman -S --needed --noconfirm zsh
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Installing Oh My Zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
	echo "Installing Powerlevel10k theme..."
	git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

# Install fonts for Powerlevel10k
echo "Installing Powerlevel10k fonts..."
git clone --depth 1 https://github.com/romkatv/powerlevel10k.git /tmp/p10k-fonts
mkdir -p ~/.local/share/fonts
cp /tmp/p10k-fonts/*.ttf ~/.local/share/fonts/ 2>/dev/null || true
fc-cache -f ~/.local/share/fonts 2>/dev/null || true
rm -rf /tmp/p10k-fonts

# Install plugin: zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
	echo "Installing zsh-autosuggestions..."
	git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

# Install plugin: zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
	echo "Installing zsh-syntax-highlighting..."
	git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# Install plugin: fast-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting" ]; then
	echo "Installing fast-syntax-highlighting..."
	git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting"
fi

# Install plugin: fzf-tab
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" ]; then
	echo "Installing fzf-tab..."
	git clone --depth 1 https://github.com/Aloxaf/fzf-tab.git "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
fi

# Install plugin: zsh-vi-mode
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode" ]; then
	echo "Installing zsh-vi-mode..."
	git clone --depth 1 https://github.com/jeffreytse/zsh-vi-mode.git "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode"
fi

# Install carapace for completion
if ! command -v carapace &>/dev/null; then
	echo "Installing carapace..."
	yay -S --noconfirm --needed carapace-bin 2>/dev/null || sudo pacman -S --noconfirm --needed carapace-bin
fi

# Copy .zshrc and .p10k.zsh to home
echo "Copying .zshrc and p10k.zsh to home directory..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
cp "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

echo "--- Oh My Zsh Installation Complete ---"
echo "Please restart your terminal or run: source ~/.zshrc"
