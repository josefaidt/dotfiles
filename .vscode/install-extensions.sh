#!/bin/bash

# File containing the list of extensions
EXTENSIONS_FILE="extensions.txt"

# Check if the file exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "File $EXTENSIONS_FILE does not exist."
    exit 1
fi

# Read the file and install each extension
while IFS= read -r extension; do
    if [ -n "$extension" ]; then
        echo "Installing extension: $extension"
        code --install-extension "$extension"
    fi
done < "$EXTENSIONS_FILE"
