#!/usr/bin/env bash
#
# greetd step: point greetd at tuigreet.
#
# Run through the installer as `sudo ./tui_greet.sh` (or `sudo ./install_all.sh
# --only greetd`). The service is enabled but NOT started: starting greetd from
# inside a running desktop session can terminate that session.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

CONFIG_FILE="${GREETD_CONFIG:-/etc/greetd/config.toml}"
NEW_COMMAND='command = "tuigreet --cmd start-hyprland --time --remember --asterisks --greeting '\'' Welcome to Hyprland '\'' --theme '\''border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red'\''"'

[[ ${EUID:-$(id -u)} -eq 0 ]] || die "run this script as root (sudo $0)"
need_cmd tuigreet

[[ -f $CONFIG_FILE ]] || die "config file not found: $CONFIG_FILE"

backup="$CONFIG_FILE.bak.$(date +%Y%m%d-%H%M%S)"
cp -a -- "$CONFIG_FILE" "$backup"
ok "backed up $CONFIG_FILE -> $backup"

# Replace only the first `command = ...` line and keep the rest of the file.
tmp="$(mktemp)"
awk -v cmd="$NEW_COMMAND" '
	BEGIN { replaced = 0 }
	!replaced && /^[[:space:]]*command[[:space:]]*=/ { print cmd; replaced = 1; next }
	{ print }
' "$CONFIG_FILE" >"$tmp"

if ! grep -qF -- "$NEW_COMMAND" "$tmp"; then
	rm -f -- "$tmp"
	die "no 'command =' line found in $CONFIG_FILE; edit it manually"
fi

install -m 644 -- "$tmp" "$CONFIG_FILE"
rm -f -- "$tmp"

ok "updated $CONFIG_FILE"

systemctl enable greetd.service
ok "enabled greetd.service (it will start on the next boot)"

printf 'Review the configuration, then reboot when you are ready.\n'
