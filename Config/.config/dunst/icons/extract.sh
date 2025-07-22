#!/bin/bash

# Paths (change as needed)
input_svg="timer.svg"
dcol_file="/home/nirantar/.cache/hyde/wall.dcol"
output_svg="clock_colored_dark.svg"

# Copy original SVG to output first
cp "$input_svg" "$output_svg"

index=1

# Read dcol file, filter dark colors and apply to SVG elements in order
grep -E '^[a-zA-Z0-9_]+="([A-Fa-f0-9]{6})"' "$dcol_file" | while IFS="=" read -r key value; do
    hex="${value//\"/}"
    # Convert hex to decimal RGB
    R=$((16#${hex:0:2}))
    G=$((16#${hex:2:2}))
    B=$((16#${hex:4:2}))

    # Calculate perceived brightness
    brightness=$(awk -v r=$R -v g=$G -v b=$B 'BEGIN { print int(0.299*r + 0.587*g + 0.114*b) }')

    if (( brightness < 100 )); then
        color="#$hex"
        echo "Applying dark color $color to element #$index"
        # Update fill attribute of the index-th SVG element (path, circle, rect)
        xmlstarlet ed -L \
            -u "(//*[name()='path' or name()='circle' or name()='rect'])[$index]/@fill" \
            -v "$color" \
            "$output_svg"
        index=$((index + 1))
    fi
done

echo "Done! Output saved as $output_svg"

