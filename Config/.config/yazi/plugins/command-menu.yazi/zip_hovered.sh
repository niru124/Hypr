#!/bin/bash
# Zip the hovered file to filename.zip
if [ $# -eq 0 ]; then
    echo "No file provided"
    exit 1
fi
file="$1"
zip_name="${file%.*}.zip"
zip "$zip_name" "$file"