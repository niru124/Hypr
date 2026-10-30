#!/usr/bin/env bash
# Shared helpers for the Hypr dotfiles installer.
#
# This file is meant to be sourced, never executed directly:
#
#   SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
#   source "$SCRIPT_DIR/lib/common.sh"
#
# It assumes the caller already enabled `set -Eeuo pipefail`.

# Guard against being sourced twice.
if [[ -n ${__HYPR_COMMON_SH:-} ]]; then
	return 0
fi
__HYPR_COMMON_SH=1

: "${SCRIPT_DIR:?SCRIPT_DIR must be set before sourcing lib/common.sh}"

if [[ -t 1 ]]; then
	C_RESET=$'\033[0m'
	C_INFO=$'\033[1;34m'
	C_OK=$'\033[1;32m'
	C_WARN=$'\033[1;33m'
	C_ERR=$'\033[1;31m'
else
	C_RESET='' C_INFO='' C_OK='' C_WARN='' C_ERR=''
fi

log() { printf '%b==>%b %s\n' "$C_INFO" "$C_RESET" "$*"; }
ok() { printf '%b  ok%b %s\n' "$C_OK" "$C_RESET" "$*"; }
warn() { printf '%bwarn%b %s\n' "$C_WARN" "$C_RESET" "$*" >&2; }
die() {
	printf '%berr %b %s\n' "$C_ERR" "$C_RESET" "$*" >&2
	exit 1
}

need_cmd() {
	local cmd
	for cmd in "$@"; do
		command -v "$cmd" >/dev/null 2>&1 || die "required command not found: $cmd"
	done
}

require_not_root() {
	if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
		die "do not run the installer as root; run it as your user (it calls sudo where needed)"
	fi
}

require_arch() {
	[[ -r /etc/os-release ]] || die "cannot read /etc/os-release; this installer only supports Arch Linux"
	# shellcheck disable=SC1091
	local id id_like
	id="$(. /etc/os-release && printf '%s' "${ID:-}")"
	id_like="$(. /etc/os-release && printf '%s' "${ID_LIKE:-}")"
	[[ $id == arch || $id_like == *arch* ]] || die "this installer only supports Arch Linux (found: ${id:-unknown})"
}

# backup_path <path> [backup_root]
# Copy <path> into a timestamped backup directory. No-op when <path> is absent.
backup_path() {
	local target=$1
	local backup_root=${2:-$HOME/.config-backup}
	local stamp dest

	[[ -e $target ]] || return 0

	stamp="$(date +%Y%m%d-%H%M%S)"
	mkdir -p -- "$backup_root"
	dest="$backup_root/$(basename -- "$target").$stamp"
	cp -a -- "$target" "$dest"
	ok "backed up $target -> $dest"
}

# read_list <file>
# Print one package per line, dropping blank lines and comments.
read_list() {
	local file=$1
	[[ -f $file ]] || die "package list not found: $file"
	sed -e 's/#.*$//' -e 's/[[:space:]]\+/ /g' -e 's/^ //' -e 's/ $//' -e '/^$/d' "$file" |
		tr ' ' '\n' | sed '/^$/d'
}

# known_pacman_pkgs <pkg>...
# Echo only the packages that exist in the sync databases.
known_pacman_pkgs() {
	local pkg
	for pkg in "$@"; do
		pacman -Si -- "$pkg" >/dev/null 2>&1 && printf '%s\n' "$pkg"
	done
}

pacman_install() {
	local -a pkgs=()
	local pkg
	for pkg in "$@"; do
		[[ -n $pkg ]] && pkgs+=("$pkg")
	done
	((${#pkgs[@]})) || return 0
	sudo pacman -S --needed --noconfirm -- "${pkgs[@]}"
}

# aur_install <pkg>...
# Install packages through yay, validating them first.
aur_install() {
	local -a pkgs=()
	local -a unknown=()
	local pkg
	for pkg in "$@"; do
		[[ -n $pkg ]] || continue
		if yay -Si -- "$pkg" >/dev/null 2>&1; then
			pkgs+=("$pkg")
		else
			unknown+=("$pkg")
		fi
	done
	if ((${#unknown[@]})); then
		warn "skipping unknown package(s): ${unknown[*]}"
	fi
	((${#pkgs[@]})) || return 0
	yay -S --needed --noconfirm -- "${pkgs[@]}"
}
