#!/bin/bash

# Define source and destination directories
SRC_DIR="$SRCROOT/Sources/AAQVendors"
INCLUDE_DIR="$SRC_DIR/include"

# Create include directory if it doesn't exist
mkdir -p "$INCLUDE_DIR"

# Function to copy headers recursively
copy_headers() {
    for item in "$1"/*; do
        if [ -d "$item" ]; then
            # If it's a directory, create it in the destination and recurse
            mkdir -p "$INCLUDE_DIR/$(basename "$item")"
            copy_headers "$item" "$(basename "$item")"
        elif [[ "$item" == *.h ]]; then
            # If it's a header file, copy it
            cp "$item" "$INCLUDE_DIR/$2/$(basename "$item")"
        fi
    done
}

# Start copying from the source directory
copy_headers "$SRC_DIR" ""