#!/usr/bin/env bash

# Paths
SHADER_DIR="$HOME/.config/hypr/hyprshader"
PERSONAL_SHADER="$SHADER_DIR/personal.glsl"
ROFI_THEME="$HOME/.config/rofi/clipboard.rasi"

# Theme styling
border_radius=13
theme_override="window { border-radius: ${border_radius}px; } element { border-radius: ${border_radius}px; }"

# Shader list
shaders=(
  "vibrance.glsl"
  "Box-Blur.glsl"
  "Fade-In.glsl"
  "Hue.glsl"
  "papers.glsl"
  "CRT.glsl"
  "grayscale.glsl"
  "invert-color.glsl"
  "Vignette.glsl"
  "yellow.glsl"
  "personal.glsl"
)

# Show shader menu
chosen=$(printf "%s\n" "${shaders[@]}" | rofi -dmenu -p "Shader" \
  -theme "$ROFI_THEME" \
  -theme-str "$theme_override")

# If personal shader selected
if [[ "$chosen" == "personal.glsl" ]]; then
    # Warmth menu
    warmth=$(rofi -dmenu -p "Warmth level:" <<< $'neutral\nmild\nwarm\nvery warm' \
      -theme "$ROFI_THEME" \
      -theme-str "$theme_override")

    # Fade menu
    fade=$(rofi -dmenu -p "Fade amount (0.0 - 1.0):" <<< $'1.0\n0.8\n0.6\n0.4\n0.2\n0.0' \
      -theme "$ROFI_THEME" \
      -theme-str "$theme_override")

    # Fallbacks
    [[ -z "$warmth" ]] && warmth="neutral"
    [[ -z "$fade" ]] && fade="1.0"

    # Convert warmth
    case "$warmth" in
        neutral)    warmTint="vec3(1.0, 1.0, 1.0)" ;;
        mild)       warmTint="vec3(1.05, 1.02, 0.95)" ;;
        warm)       warmTint="vec3(1.1, 1.05, 0.9)" ;;
        "very warm")warmTint="vec3(1.3, 1.15, 0.7)" ;;
        *)          warmTint="vec3(1.0, 1.0, 1.0)" ;;
    esac

    # Replace values in personal.glsl
    sed -i "s/^float u_FadeAmount *= *.*/float u_FadeAmount = $fade;/" "$PERSONAL_SHADER"
    sed -i "s/^vec3 warmTint *= *.*/vec3 warmTint = $warmTint;/" "$PERSONAL_SHADER"

    # Notify + toggle
    notify-send "HyprShader: Personal" "Warmth: $warmth | Fade: $fade"
    hyprshade toggle "$chosen"

elif [[ -n "$chosen" ]]; then
    hyprshade toggle "$chosen"
fi

