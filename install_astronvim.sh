#!/usr/bin/env bash
#
# AstroNvim step: replace ~/.config/nvim with the AstroNvim template plus the
# repository's nvim configuration. The previous configuration is backed up.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

NVIM_CONFIG="$HOME/.config/nvim"
LOCAL_CONFIG="$SCRIPT_DIR/Config/.config/nvim"

require_not_root
need_cmd git

log "astronvim: installing configuration"

if [[ -d $NVIM_CONFIG ]]; then
	backup_path "$NVIM_CONFIG" "$HOME/.config-backup"
	rm -rf -- "$NVIM_CONFIG"
fi

git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_CONFIG"
rm -rf -- "$NVIM_CONFIG/.git"

if [[ -d $LOCAL_CONFIG ]]; then
	log "overlaying the repository nvim configuration"
	cp -a -- "$LOCAL_CONFIG/." "$NVIM_CONFIG/"
else
	warn "$LOCAL_CONFIG not found; using the plain AstroNvim template"
fi

if command -v nvim >/dev/null 2>&1; then
	log "syncing plugins with Lazy (this can take a while)"
	nvim --headless "+Lazy! sync" +qa 2>/dev/null || warn "Lazy sync failed; run ':Lazy sync' inside nvim"
else
	warn "nvim is not installed; skipping the initial plugin sync"
fi

ok "astronvim step complete"
