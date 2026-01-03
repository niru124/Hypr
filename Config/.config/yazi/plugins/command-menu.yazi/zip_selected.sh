#!/bin/bash
# Zip selected files to selected.zip
if [ $# -eq 0 ]; then
    echo "No files selected"
    exit 1
fi
zip selected.zip "$@"