#!/usr/bin/env bash
#
# Themes step: install the GTK theme and the cursor theme from themes/*.zip.
#
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

THEMES_SRC="$SCRIPT_DIR/themes"
TMP_DIR=""

cleanup() {
	[[ -n $TMP_DIR && -d $TMP_DIR ]] && rm -rf -- "$TMP_DIR"
}
trap cleanup EXIT

require_not_root
need_cmd unzip

log "themes: GTK theme and cursor theme"

mapfile -t ZIPS < <(find "$THEMES_SRC" -maxdepth 1 -type f -name '*.zip' | sort)
((${#ZIPS[@]})) || die "no .zip archives found in $THEMES_SRC"

mkdir -p -- "$HOME/.themes" "$HOME/.icons"
TMP_DIR="$(mktemp -d)"

for zip in "${ZIPS[@]}"; do
	name="$(basename -- "$zip" .zip)"
	log "extracting $name"

	if ! unzip -tq "$zip" >/dev/null 2>&1; then
		die "$zip is not a valid zip archive"
	fi

	out="$TMP_DIR/$name"
	mkdir -p -- "$out"
	unzip -qo "$zip" -d "$out"

	# The archive must contain at least one regular file, otherwise there is
	# nothing to install (the zip files in this repo are empty stubs).
	if [[ -z $(find "$out" -type f -print -quit) ]]; then
		die "$zip contains no files; re-create it before running the installer"
	fi

	case $name in
	Bibata*) dest="$HOME/.icons" ;;
	*) dest="$HOME/.themes" ;;
	esac

	# Copy the archive's top-level directory (if any) plus stray files.
	while IFS= read -r -d '' entry; do
		cp -a -- "$entry" "$dest/"
	done < <(find "$out" -mindepth 1 -maxdepth 1 -print0)

	ok "$name installed into $dest"
done

ok "themes step complete"
