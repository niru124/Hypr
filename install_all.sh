#!/usr/bin/env bash
#
# Hypr dotfiles installer - single entry point.
#
# Usage:
#   ./install_all.sh                 # interactive, asks before each component
#   ./install_all.sh --yes           # non-interactive, accept all prompts
#   ./install_all.sh --dry-run       # only print what would run
#   ./install_all.sh --only core,zsh # run only the listed components
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ASSUME_YES=0
DRY_RUN=0
ONLY=""

usage() {
	cat <<'EOF'
Hypr dotfiles installer

Options:
  -y, --yes          accept every prompt (non-interactive)
  -n, --dry-run      print the steps that would run, change nothing
      --only LIST    comma-separated components to run, e.g. core,zsh,fonts
  -h, --help         show this help and exit

Components:
  core        pacman/AUR packages, dotfiles, helper scripts
  zsh         Oh My Zsh, Powerlevel10k, plugins, .zshrc
  wallpapers  wallpaper collection
  gpu         GPU drivers
  fonts       Nerd Fonts
  pyprland    pyprland (Hyprland plugin manager layer)
  greetd      greetd/tuigreet configuration (needs sudo)
  astronvim   AstroNvim configuration
  vim         ~/.vimrc
  tmux_keyd   tmux config + keyd remapping (needs sudo)
  themes      GTK theme and cursor theme
  optional    optional packages (fzf picker)

Examples:
  ./install_all.sh --only core,zsh
  ./install_all.sh --yes --only core
EOF
}

while (($#)); do
	case $1 in
	-y | --yes) ASSUME_YES=1 ;;
	-n | --dry-run) DRY_RUN=1 ;;
	--only)
		[[ -n ${2:-} ]] || die "--only needs a value, e.g. --only core,zsh"
		ONLY=$2
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*) die "unknown option: $1 (try --help)" ;;
	esac
	shift
done

export HYPR_ASSUME_YES=$ASSUME_YES

confirm() {
	((ASSUME_YES)) && return 0
	local reply=''
	printf '%s [y/N] ' "Run: $1"
	read -r -n 1 reply || true
	printf '\n'
	[[ $reply =~ ^[Yy]$ ]]
}

want() {
	[[ -z $ONLY ]] && return 0
	[[ ",$ONLY," == *",$1,"* ]]
}

run_step() {
	local name=$1 script=$2 use_sudo=${3:-}

	want "$name" || return 0
	[[ -f $SCRIPT_DIR/$script ]] || {
		warn "$script not found, skipping"
		return 0
	}

	if ((DRY_RUN)); then
		log "[dry-run] would run $script${use_sudo:+ (with sudo)}"
		return 0
	fi

	confirm "$name" || return 0

	chmod +x -- "$SCRIPT_DIR/$script"
	log "running $script"
	if [[ $use_sudo == sudo ]]; then
		sudo "$SCRIPT_DIR/$script"
	else
		"$SCRIPT_DIR/$script"
	fi
	ok "$name finished"
}

printf '\n%s\n\n' "Hypr dotfiles installation"
printf 'Repo: %s\n\n' "$SCRIPT_DIR"

require_not_root
require_arch

run_step core install_core.sh
run_step zsh install_zsh.sh
run_step wallpapers install_wallpapers.sh
run_step gpu install_gpu_drivers.sh
run_step fonts install_fonts.sh
run_step pyprland pyprland.sh
run_step greetd tui_greet.sh sudo
run_step astronvim install_astronvim.sh
run_step vim vim.sh
run_step tmux_keyd tmux_and_keyd.sh
run_step themes install_themes.sh
run_step optional install_non_essential.sh

# install_hyprpm_plugins.sh is intentionally not part of the default flow:
# Hyprland >= 0.56 ships a native `scrolling` layout that supersedes the
# hyprscroller plugin. Run it manually only if you know you need it.

printf '\n'
ok "all requested components processed"
printf 'Log out and back in (or reboot) to pick up shell and service changes.\n'
