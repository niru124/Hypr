#!/usr/bin/env bash
#
# Optional packages step: pick extras with fzf (or install all when
# non-interactive) from non-essential.txt.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

PACKAGE_FILE="$SCRIPT_DIR/non-essential.txt"

require_not_root
need_cmd yay

log "optional packages from $(basename -- "$PACKAGE_FILE")"

mapfile -t PACKAGES < <(read_list "$PACKAGE_FILE")
((${#PACKAGES[@]})) || die "no packages listed in $PACKAGE_FILE"

if [[ -t 0 && ${HYPR_ASSUME_YES:-0} -eq 0 ]]; then
	need_cmd fzf
	mapfile -t SELECTED < <(
		printf '%s\n' "${PACKAGES[@]}" |
			fzf -m --prompt="Select optional packages (Tab = select, Enter = confirm): " || true
	)
else
	SELECTED=("${PACKAGES[@]}")
fi

if ((${#SELECTED[@]} == 0)); then
	log "no packages selected"
	exit 0
fi

log "installing ${#SELECTED[@]} package(s)"
aur_install "${SELECTED[@]}"

ok "optional packages step complete"
