#!/usr/bin/env bash
# matugen post-hook: merge dunst template into dunstrc and reload
set -u
export hypr_border="${hypr_border:-10}"
if command -v envsubst >/dev/null 2>&1 && [ -f "$HOME/.config/dunst/dunst.conf" ]; then
  envsubst < "$HOME/.config/dunst/dunst.conf" > "$HOME/.config/dunst/dunstrc"
else
  cp "$HOME/.config/dunst/dunst.conf" "$HOME/.config/dunst/dunstrc" 2>/dev/null || true
fi
[ -f "$HOME/.config/dunst/matugen.conf" ] && cat "$HOME/.config/dunst/matugen.conf" >> "$HOME/.config/dunst/dunstrc"
pkill -x dunst 2>/dev/null || true
setsid -f dunst </dev/null >/dev/null 2>&1 || true
