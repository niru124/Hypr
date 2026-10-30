#!/usr/bin/env bash
#
# Wallpapers step: clone the themes repository into ~/.config/hyde/themes.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

THEMES_REPO="${THEMES_REPO:-https://github.com/niru124/themes}"
WALLPAPER_DIR="$HOME/.config/hyde/themes"
TMP_DIR=""

cleanup() {
	[[ -n $TMP_DIR && -d $TMP_DIR ]] && rm -rf -- "$TMP_DIR"
}
trap cleanup EXIT

require_not_root
need_cmd git

log "wallpapers: cloning $THEMES_REPO"

TMP_DIR="$(mktemp -d)"
if ! git clone --depth 1 "$THEMES_REPO" "$TMP_DIR/repo"; then
	die "could not clone $THEMES_REPO (is the repository public?)"
fi

mkdir -p -- "$WALLPAPER_DIR"

if [[ -d $TMP_DIR/repo/themes ]]; then
	rsync -a -- "$TMP_DIR/repo/themes/" "$WALLPAPER_DIR/"
else
	rsync -a --exclude='/.git/' -- "$TMP_DIR/repo/" "$WALLPAPER_DIR/"
fi

ok "wallpapers installed into $WALLPAPER_DIR"
