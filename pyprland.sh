#!/usr/bin/env bash
#
# pyprland step: install pyprland and refresh hyprpm when it is available.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_not_root
need_cmd yay

log "pyprland: installing"

aur_install pyprland

# hyprpm only exists when Hyprland was built with it; skip silently otherwise.
if command -v hyprpm >/dev/null 2>&1; then
	log "updating hyprpm headers"
	hyprpm update || warn "hyprpm update failed"
else
	warn "hyprpm not found; skipping header update (pyprland itself is installed)"
fi

ok "pyprland step complete"
