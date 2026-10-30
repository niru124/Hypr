#!/usr/bin/env bash
#
# tmux + keyd step: install .tmux.conf, TPM and the keyd remapping.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

TMUX_SOURCE="$SCRIPT_DIR/Config/.config/tmux/.tmux.conf"
TMUX_DEST="$HOME/.tmux.conf"
KEYD_SOURCE="$SCRIPT_DIR/keyd/default.conf"
KEYD_DEST="/etc/keyd/default.conf"

require_not_root
need_cmd git

log "tmux + keyd"

if [[ -f $TMUX_SOURCE ]]; then
	backup_path "$TMUX_DEST"
	install -m 644 -- "$TMUX_SOURCE" "$TMUX_DEST"
	ok "installed $TMUX_DEST"
else
	warn ".tmux.conf not found at $TMUX_SOURCE"
fi

if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
	log "installing TPM"
	git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
	ok "installed TPM"
else
	ok "TPM already installed"
fi

if [[ ! -f $KEYD_SOURCE ]]; then
	warn "keyd config not found at $KEYD_SOURCE"
	exit 0
fi

command -v keyd >/dev/null 2>&1 || pacman_install keyd

sudo mkdir -p -- "$(dirname -- "$KEYD_DEST")"
if [[ -f $KEYD_DEST ]]; then
	backup="/etc/keyd/default.conf.bak.$(date +%Y%m%d-%H%M%S)"
	sudo cp -a -- "$KEYD_DEST" "$backup"
	ok "backed up $KEYD_DEST -> $backup"
fi
sudo install -m 644 -- "$KEYD_SOURCE" "$KEYD_DEST"
ok "installed $KEYD_DEST"

sudo systemctl enable --now keyd.service
ok "keyd enabled and running"

ok "tmux + keyd step complete"
