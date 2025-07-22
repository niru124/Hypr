#!/bin/bash

# Check if a filename is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <file_name> [quality] [density]"
  exit 1
fi

# Get the file name, quality, and density (default to 100 for quality and 150x150 for density)
FILE="$1"
QUALITY="${2:-100}"
DENSITY="${3:-150x150}"

# Check the file extension to determine if it's a PDF or an image
EXT="${FILE##*.}"

# Function to compress PDF
compress_pdf() {
  INPUT="$1"
  OUTPUT="compressed.pdf"
  
  echo "Compressing PDF: $INPUT with quality $QUALITY and density $DENSITY..."
  convert -density $DENSITY -quality $QUALITY "$INPUT" "$OUTPUT"
  echo "PDF compressed successfully: $OUTPUT"
}

# Function to compress Image
compress_image() {
  INPUT="$1"
  OUTPUT="compressed_image.jpg"
  
  echo "Compressing image: $INPUT with quality $QUALITY..."
  convert "$INPUT" -quality $QUALITY "$OUTPUT"
  echo "Image compressed successfully: $OUTPUT"
}

# Check file extension and call respective compression function
if [[ "$EXT" == "pdf" ]]; then
  compress_pdf "$FILE"
elif [[ "$EXT" == "jpg" || "$EXT" == "jpeg" || "$EXT" == "png" ]]; then
  compress_image "$FILE"
else
  echo "Unsupported file type. Please provide a PDF or image file (jpg, jpeg, or png)."
  exit 1
fi

