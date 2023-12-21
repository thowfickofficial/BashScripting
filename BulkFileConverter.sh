#!/bin/bash

# Check if 'convert' command (ImageMagick) is available
if ! command -v convert &> /dev/null; then
    echo "ImageMagick 'convert' command not found. Please install ImageMagick."
    exit 1
fi

# Function to prompt the user for a directory and validate its existence
prompt_for_directory() {
    local dir
    read -p "Enter the $1 directory: " dir
    dir="${dir/#\~/$HOME}" # Expand ~ to user's home directory
    if [ ! -d "$dir" ]; then
        echo "Directory '$dir' does not exist."
        exit 1
    fi
    echo "$dir"
}

# Prompt the user for source and destination directories
SRC_DIR=$(prompt_for_directory "source")
DEST_DIR=$(prompt_for_directory "destination")

# Source and destination file extensions
echo "Supported input formats: jpg, jpeg, png, gif, bmp, tiff"
read -p "Enter the source file extension (e.g., jpg): " SRC_EXT
read -p "Enter the destination file extension (e.g., png): " DEST_EXT

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Loop through the source directory and convert files
for file in "$SRC_DIR"/*."$SRC_EXT"; do
    if [ -f "$file" ]; then
        # Get the base filename without extension
        filename=$(basename -- "$file")
        filename_noext="${filename%.*}"

        # Construct the destination file path
        dest_file="$DEST_DIR/$filename_noext.$DEST_EXT"

        # Perform the conversion
        convert "$file" "$dest_file"

        # Optionally, you can remove the source file after conversion
        # Uncomment the line below to enable this
        # rm "$file"

        echo "Converted: $file to $dest_file"
    fi
done

echo "Conversion complete."
