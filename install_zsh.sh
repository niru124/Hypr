#!/usr/bin/env bash
#
# Zsh step: Oh My Zsh, Powerlevel10k, plugins and shell dotfiles.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

require_not_root
need_cmd git
need_cmd curl

log "zsh: Oh My Zsh, Powerlevel10k and plugins"

pacman_install zsh

if [[ ! -d $HOME/.oh-my-zsh ]]; then
	log "installing Oh My Zsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
	ok "Oh My Zsh already installed"
fi

if [[ ! -d $P10K_DIR ]]; then
	log "installing Powerlevel10k"
	git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
	ok "Powerlevel10k already installed"
fi

# The MesloLGS NF fonts ship inside the Powerlevel10k repository, so reuse
# that clone instead of fetching it a second time into /tmp.
if compgen -G "$P10K_DIR/*.ttf" >/dev/null; then
	log "installing Powerlevel10k fonts"
	mkdir -p -- "$HOME/.local/share/fonts"
	cp -f -- "$P10K_DIR/"*.ttf "$HOME/.local/share/fonts/"
	fc-cache -f "$HOME/.local/share/fonts" >/dev/null
	ok "fonts installed"
fi

clone_plugin() {
	local name=$1 url=$2 dir="$ZSH_CUSTOM/plugins/$1"
	if [[ -d $dir ]]; then
		ok "$name already installed"
		return 0
	fi
	log "installing $name"
	git clone --depth 1 "$url" "$dir"
}

clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
clone_plugin fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git
clone_plugin fzf-tab https://github.com/Aloxaf/fzf-tab.git
clone_plugin zsh-vi-mode https://github.com/jeffreytse/zsh-vi-mode.git

if ! command -v carapace >/dev/null 2>&1; then
	log "installing carapace"
	if ! command -v yay >/dev/null 2>&1 || ! aur_install carapace-bin; then
		pacman_install carapace
	fi
fi

# Back up the previous shell config before replacing it.
backup_path "$HOME/.zshrc"
backup_path "$HOME/.p10k.zsh"

log "installing .zshrc and .p10k.zsh"
install -m 644 -- "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
install -m 644 -- "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

if [[ ${SHELL:-} != *zsh ]]; then
	log "setting zsh as the default shell"
	chsh -s "$(command -v zsh)" || warn "chsh failed; change your shell manually with: chsh -s $(command -v zsh)"
fi

ok "zsh step complete (restart your terminal or run: source ~/.zshrc)"
