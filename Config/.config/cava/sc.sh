#!/bin/bash

# Check for shader argument
if [ -z "$1" ]; then
    echo "Usage: $0 <shader_name (without .frag)>"
    exit 1
fi

SHADER_NAME="$1"
SHADER_DIR="$HOME/.config/cava/shaders"
FRAG_SHADER="$SHADER_DIR/$SHADER_NAME.frag"
VERT_SHADER="$SHADER_DIR/pass_through.vert"
CAVA_PIPE="/tmp/cava.raw"
BARS=128

# Check if fragment shader exists
if [ ! -f "$FRAG_SHADER" ]; then
    echo "Shader $FRAG_SHADER not found."
    exit 2
fi

# Kill old instances
pkill cava 2>/dev/null
pkill hyprshade 2>/dev/null

# Start cava
cava &
sleep 1  # wait for pipe to be ready

# Start hyprshade using correct command
hyprshade run \
  --pipe "$CAVA_PIPE" \
  --bars "$BARS" \
  --frag "$FRAG_SHADER" \
  --vert "$VERT_SHADER"

