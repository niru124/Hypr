#!/usr/bin/env bash
#
# GPU drivers step: install the userspace driver stack matching the hardware.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_not_root
need_cmd lspci

log "gpu: detecting hardware"

# Only look at display controllers; matching "amd" anywhere also hits CPUs,
# chipsets and USB controllers.
controllers="$(lspci -nn | grep -Ei 'vga compatible controller|3d controller|display controller' || true)"
[[ -n $controllers ]] || die "no display controller found"

log "found:"
printf '%s\n' "$controllers" | sed 's/^/    /'

has() { grep -qi -- "$1" <<<"$controllers"; }

pkgs=()
if has nvidia; then
	pkgs+=(nvidia nvidia-utils nvidia-settings libva-nvidia-driver)
fi
if has 'amd\|ati'; then
	pkgs+=(mesa vulkan-radeon libva-mesa-driver mesa-utils)
fi
if has intel; then
	pkgs+=(mesa vulkan-intel intel-media-driver mesa-utils)
fi

if ((${#pkgs[@]} == 0)); then
	warn "no known GPU vendor matched; installing the generic Mesa stack"
	pkgs+=(mesa mesa-utils)
fi

# Deduplicate while preserving order.
mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | awk '!seen[$0]++')

pacman_install linux-firmware "${pkgs[@]}"

ok "gpu step complete"
