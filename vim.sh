#!/usr/bin/env bash
#
# vim step: install ~/.vimrc.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

VIM_SOURCE="$SCRIPT_DIR/.vimrc"
VIM_DEST="$HOME/.vimrc"

require_not_root

[[ -f $VIM_SOURCE ]] || die "vim config not found at $VIM_SOURCE"

if ! command -v vim >/dev/null 2>&1; then
	warn "vim is not installed (pacman -S vim); installing the config anyway"
fi

backup_path "$VIM_DEST"
install -m 644 -- "$VIM_SOURCE" "$VIM_DEST"

ok "installed $VIM_DEST"
