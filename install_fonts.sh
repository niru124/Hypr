#!/usr/bin/env bash
#
# Fonts step: Nerd Fonts, emoji font and two display fonts.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

FONT_ROOT="$HOME/.local/share/fonts"
TMP_DIR=""

cleanup() {
	[[ -n $TMP_DIR && -d $TMP_DIR ]] && rm -rf -- "$TMP_DIR"
}
trap cleanup EXIT

require_not_root
pacman_install curl unzip
need_cmd curl
need_cmd unzip

log "fonts: installing Nerd Fonts"

TMP_DIR="$(mktemp -d)"

# download_zip <url> <dest-dir>
download_zip() {
	local url=$1 dest=$2 zip
	zip="$(mktemp -p "$TMP_DIR" --suffix=.zip)"
	curl -fL --retry 3 --connect-timeout 15 -o "$zip" "$url" || return 1
	unzip -tq "$zip" >/dev/null 2>&1 || {
		warn "download is not a valid zip archive: $url"
		return 1
	}
	unzip -qo "$zip" -d "$dest"
}

install_nerd_font() {
	local name=$1
	local dest="$FONT_ROOT/$name"
	log "installing $name Nerd Font"
	mkdir -p -- "$dest"
	download_zip \
		"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${name}.zip" \
		"$dest" || {
		warn "could not install the $name Nerd Font"
		return 1
	}
}

install_custom_font() {
	local name=$1 url=$2
	local dest="$FONT_ROOT/$name"
	log "installing $name"
	mkdir -p -- "$dest"
	download_zip "$url" "$dest" || {
		warn "could not install $name (the upstream URL is unreliable; install it manually)"
		return 1
	}
}

fails=0
install_nerd_font CaskaydiaCove || fails=$((fails + 1))
install_nerd_font 0xProto || fails=$((fails + 1))
install_nerd_font JetBrainsMono || fails=$((fails + 1))
install_nerd_font GeistMono || fails=$((fails + 1))

pacman_install noto-fonts-emoji

# These two come from font-sharing sites that are not guaranteed to stay up.
install_custom_font Abocat "https://font.download/dl/font/abocat.zip" || fails=$((fails + 1))
install_custom_font Steelfish "https://dl.dafont.com/dl/?f=steelfish" || fails=$((fails + 1))
install_custom_font Mexcellent "https://dl.dafont.com/dl/?f=mexcellent" || fails=$((fails + 1))

log "updating font cache"
fc-cache -f "$FONT_ROOT" >/dev/null

if ((fails)); then
	warn "$fails font(s) could not be installed; see the messages above"
fi

ok "fonts step complete"
