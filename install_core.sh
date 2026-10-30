#!/usr/bin/env bash
#
# Core step: install pacman/AUR packages, copy dotfiles and helper scripts.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

PACMAN_LIST="$SCRIPT_DIR/pacman_necessary.txt"
AUR_LIST="$SCRIPT_DIR/yay_necessary.txt"
CONFIG_DIR="$SCRIPT_DIR/Config/.config"
BIN_DIR="$SCRIPT_DIR/bin2"
BIN_TARGET="$HOME/.local/share/bin"

require_not_root
require_arch
need_cmd git

log "core: packages, dotfiles and scripts"

# --- yay ---------------------------------------------------------------------
if ! command -v yay >/dev/null 2>&1; then
	log "building yay from the AUR"
	pacman_install base-devel fakeroot binutils
	YAY_DIR="$(mktemp -d)"
	# shellcheck disable=SC2064
	trap 'rm -rf -- "$YAY_DIR"' EXIT
	git clone --depth 1 https://aur.archlinux.org/yay.git "$YAY_DIR"
	(
		cd -- "$YAY_DIR"
		makepkg -si --noconfirm
	)
	rm -rf -- "$YAY_DIR"
	trap - EXIT
	ok "yay installed"
else
	ok "yay already installed"
fi

# --- pacman packages ---------------------------------------------------------
pacman_install fzf

mapfile -t PACMAN_PKGS < <(read_list "$PACMAN_LIST")
if ((${#PACMAN_PKGS[@]})); then
	mapfile -t KNOWN < <(known_pacman_pkgs "${PACMAN_PKGS[@]}")
	if ((${#KNOWN[@]} < ${#PACMAN_PKGS[@]})); then
		warn "some packages in $(basename -- "$PACMAN_LIST") are unknown to pacman and will be skipped"
	fi
	pacman_install "${KNOWN[@]}"
fi

# matugen is in the CachyOS/chaotic repos as `matugen`, but on plain Arch it is
# only available from the AUR. swwwallpaper.sh needs it for theming.
if ! command -v matugen >/dev/null 2>&1; then
	aur_install matugen-bin || true
	command -v matugen >/dev/null 2>&1 ||
		warn "matugen is not installed; wallpaper theming will not work"
fi

# --- AUR packages ------------------------------------------------------------
mapfile -t AUR_PKGS < <(read_list "$AUR_LIST")
if ((${#AUR_PKGS[@]})); then
	if [[ -t 0 && ${HYPR_ASSUME_YES:-0} -eq 0 ]]; then
		mapfile -t SELECTED < <(
			printf '%s\n' "${AUR_PKGS[@]}" |
				fzf -m --prompt="Select AUR packages (Tab = select, Enter = confirm): " || true
		)
	else
		SELECTED=("${AUR_PKGS[@]}")
	fi

	if ((${#SELECTED[@]})); then
		aur_install "${SELECTED[@]}"
		ok "AUR packages processed (${#SELECTED[@]})"
	else
		log "no AUR packages selected"
	fi
fi

# --- dotfiles ----------------------------------------------------------------
if [[ -d $CONFIG_DIR ]] && [[ -n $(ls -A -- "$CONFIG_DIR") ]]; then
	log "copying dotfiles into ~/.config (existing files are backed up)"
	TOP_BACKUP="$HOME/.config-backup/$(date +%F_%H%M%S)"
	mkdir -p -- "$TOP_BACKUP"
	# --backup-dir only stores files that are actually overwritten, so this
	# stays cheap even when ~/.config is large.
	rsync -a \
		--backup --backup-dir="$TOP_BACKUP/config" \
		--exclude='/files.txt' \
		--exclude='/nvim_/' \
		-- "$CONFIG_DIR/" "$HOME/.config/"
	ln -sfn -- "$TOP_BACKUP" "$HOME/.config-backup/latest"
	ok "dotfiles installed (backup: $TOP_BACKUP)"
else
	warn "$CONFIG_DIR is missing or empty; skipping dotfiles"
fi

# --- helper scripts ----------------------------------------------------------
if [[ -d $BIN_DIR ]] && [[ -n $(ls -A -- "$BIN_DIR") ]]; then
	log "installing helper scripts into $BIN_TARGET"
	mkdir -p -- "$BIN_TARGET"
	rsync -a -- "$BIN_DIR/" "$BIN_TARGET/"
	find "$BIN_TARGET" -type f -exec chmod +x {} +
	ok "scripts installed"
else
	warn "$BIN_DIR is missing or empty; skipping scripts"
fi

# rtrash wrapper (idempotent: -f, and only if the source exists)
if [[ -f $HOME/.config/ranger/rtrash ]]; then
	mkdir -p -- "$HOME/.local/bin"
	ln -sfn -- "$HOME/.config/ranger/rtrash" "$HOME/.local/bin/rtrash"
	ok "linked rtrash into ~/.local/bin"
else
	warn "~/.config/ranger/rtrash not found; skipping rtrash link"
fi

# --- bluetooth ---------------------------------------------------------------
if systemctl list-unit-files bluetooth.service >/dev/null 2>&1; then
	sudo systemctl enable --now bluetooth.service ||
		warn "could not enable bluetooth.service (no adapter?)"
fi

ok "core step complete"
