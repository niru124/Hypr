#!/usr/bin/env bash
# Recolor dunst vol dial icons (brightness/volume OSD) from matugen waybar theme.
# Mapping (dark bg, light accents): active arc -> wb-accent, track/needle ->
# wb-outline, outer ring -> main-bg, inner circle -> wb-hvr-bg.
set -u
theme="$HOME/.config/waybar/theme.css"
dir="$HOME/.config/dunst/icons/vol"
[ -f "$theme" ] && [ -d "$dir" ] || exit 0
python3 - "$theme" "$dir" <<'EOF'
import re, sys, glob
css = open(sys.argv[1]).read()
d = sys.argv[2]
def get(name):
    m = re.search(rf'@define-color {name} rgba\((\d+),\s*(\d+),\s*(\d+)', css)
    return '#%02x%02x%02x' % tuple(map(int, m.groups())) if m else None
accent = get('wb-accent'); outline = get('wb-outline')
bg = get('main-bg'); sec = get('wb-hvr-bg')
if not all([accent, outline, bg, sec]):
    sys.exit(0)
mapping = {'#e4a4a3': accent, '#433235': outline, '#5b4244': bg, '#725252': sec}
for f in glob.glob(f"{d}/vol-*.svg"):
    s = open(f).read()
    orig = s
    for old, new in mapping.items():
        s = re.sub(re.escape(old), new, s, flags=re.IGNORECASE)
    if s != orig:
        open(f, 'w').write(s)
        print(f"recolored {f}")
EOF
