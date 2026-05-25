#!/usr/bin/env python3
import re, os

src_dir = os.path.expanduser("~/.config/hypr/animations")
out_dir = src_dir

def convert_bool(val):
    val = val.strip()
    return "true" if val in ("yes", "true", "1") else "false"

for fname in sorted(os.listdir(src_dir)):
    if not fname.endswith(".conf"):
        continue
    conf_path = os.path.join(src_dir, fname)
    base = os.path.basename(fname)
    name = base.replace(".conf", "")
    lua_path = os.path.join(out_dir, name + ".lua")

    with open(conf_path) as f:
        text = f.read()

    lines = text.splitlines()
    out_lines = []
    in_animations = False

    for line in lines:
        stripped = line.strip()
        stripped_no_comment = stripped.split("#")[0].rstrip() if "#" in stripped else stripped

        if stripped == "animations {":
            in_animations = True
            continue
        if stripped == "}":
            in_animations = False
            continue

        if not in_animations:
            # Convert comment prefix # to --
            if stripped.startswith("#"):
                out_lines.append("--" + stripped[1:])
            elif stripped:
                out_lines.append("-- " + stripped)
            else:
                out_lines.append("")
            continue

        # Inside animations block
        if not stripped:
            continue

        # Convert # comments to Lua comments
        if stripped.startswith("#"):
            out_lines.append("--" + stripped[1:])
            continue

        # Skip enabled line
        m_enabled = re.match(r'enabled\s*=\s*(\S+)', stripped_no_comment)
        if m_enabled:
            continue

        m_bezier = re.match(r'bezier\s*=\s*(\w+),\s*([\d.-]+),\s*([\d.-]+),\s*([\d.-]+),\s*([\d.-]+)', stripped)
        if m_bezier:
            name_b = m_bezier.group(1)
            x0, y0, x1, y1 = m_bezier.group(2), m_bezier.group(3), m_bezier.group(4), m_bezier.group(5)
            indent = line[:len(line) - len(line.lstrip())]
            out_lines.append(f'hl.curve("{name_b}", {{ type = "bezier", points = {{{{{x0}, {y0}}}, {{{x1}, {y1}}}}} }})')
            continue

        m_anim = re.match(r'animation\s*=\s*(\w+),\s*(\S+),\s*([\d.]+),\s*(\w+)(?:\s*,\s*(.*))?', stripped)
        if m_anim:
            leaf = m_anim.group(1)
            enabled = convert_bool(m_anim.group(2))
            speed = m_anim.group(3)
            curve = m_anim.group(4)
            style = m_anim.group(5)
            if style:
                style = style.split("#")[0].strip()
            lua = f'hl.animation({{ leaf = "{leaf}", enabled = {enabled}, speed = {speed}, curve = "{curve}"'
            if style:
                lua += f', style = "{style}"'
            lua += " })"
            out_lines.append(lua)
            continue

        # Unknown line - preserve as comment
        out_lines.append("-- " + stripped)

    with open(lua_path, "w") as f:
        f.write("-- Auto-converted from " + base + "\n")
        f.write("-- See https://wiki.hyprland.org/Configuring/Animations/\n")
        f.write("\n".join(out_lines))
        f.write("\n")

    print(f"OK: {base} -> {name}.lua")
