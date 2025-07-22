#!/bin/bash

# Check if required tools are installed
if ! command -v grimblast &> /dev/null; then
    echo "grimblast is not installed. Please install it and try again."
    exit 1
fi

if ! command -v tesseract &> /dev/null; then
    echo "Tesseract is not installed. Please install it and try again."
    exit 1
fi

if ! command -v wl-copy &> /dev/null; then
    echo "wl-copy is not installed. Please install it and try again."
    exit 1
fi

# Define a temporary image path
temp_image="/tmp/selected_area.png"

# Capture selected area with grimblast
echo "Select an area with your mouse..."
grimblast save area "$temp_image"

# Check if the image was created
if [[ ! -f "$temp_image" ]]; then
    echo "Failed to capture the selected area."
    exit 1
fi

# Use tesseract to extract text from the captured image
extracted_text=$(tesseract "$temp_image" stdout)

# Check if text extraction was successful
if [[ -z "$extracted_text" ]]; then
    echo "No text extracted from the image."
    rm "$temp_image"
    exit 1
fi

# Copy the extracted text to the clipboard
echo "$extracted_text" | wl-copy

# Clean up the temporary image
rm "$temp_image"

echo "Text copied to clipboard!"

