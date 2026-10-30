#!/usr/bin/env bash
#
# Optional, manual step: install the hyprscroller hyprpm plugin.
#
# Hyprland >= 0.56 ships a native `scrolling` layout which supersedes this
# plugin. Only run this script if you explicitly want the plugin, and make sure
# your hyprland.conf uses `general:layout = hyprscroller` afterwards.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_not_root

if ! command -v hyprpm >/dev/null 2>&1; then
	die "hyprpm not found; install Hyprland (or hyprland-git) with hyprpm support first"
fi

warn "hyprscroller is deprecated on Hyprland >= 0.56 (native scrolling layout exists)"
printf 'Press Enter to continue, Ctrl-C to abort... '
read -r _ || true

log "updating hyprpm headers"
hyprpm update

log "adding hyprscroller"
hyprpm add https://github.com/cpiber/hyprscroller
hyprpm enable hyprscroller

ok "hyprscroller installed; run 'hyprpm reload' or restart Hyprland"
