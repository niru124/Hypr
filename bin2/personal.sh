#!/bin/bash

# Ask for warmth level
warmth=$(rofi -dmenu -p "Select warmth level:" -lines 4 <<< $'neutral\nmild\nwarm\nvery warm')

# Ask for fade amount (optional)
fade=$(rofi -dmenu -p "Set fade (0.0 - 1.0):" -lines 5 <<< $'1.0\n0.8\n0.6\n0.4\n0.2')

# Set warmTint based on selection
case "$warmth" in
    neutral)
        warmTint="vec3(1.0, 1.0, 1.0)" ;;
    mild)
        warmTint="vec3(1.05, 1.02, 0.95)" ;;
    warm)
        warmTint="vec3(1.1, 1.05, 0.9)" ;;
    "very warm")
        warmTint="vec3(1.3, 1.15, 0.7)" ;;
    *)
        warmTint="vec3(1.0, 1.0, 1.0)" ;;
esac

# Clamp fade value to safe range
if [[ -z "$fade" ]]; then fade="1.0"; fi

# Write to shader config include or replace variables in your shader
CONFIG_PATH="$HOME/.config/hypr/hyprshader/uniforms.glsl"

cat > "$CONFIG_PATH" <<EOF
uniform float u_FadeAmount = $fade;
uniform vec3 warmTint = $warmTint;
EOF

# (Optional) trigger HyprShader reload if needed
# This depends on your setup. You might reload Hyprland or send a signal.
# e.g., hyprctl reload or pkill -SIGUSR1 hyprland

notify-send "HyprShader updated" "Warmth: $warmth | Fade: $fade"
