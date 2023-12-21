#!/bin/bash

# Function to generate the directory tree
generate_tree() {
    local dir="$1"
    local prefix="$2"
    local dir_color="\e[34m"  # Blue color for directories
    local file_color="\e[32m" # Green color for files
    local reset_color="\e[0m" # Reset color

    # Display the current directory with color
    echo -e "${dir_color}${prefix}├── $(basename "$dir")/${reset_color}"

    # List all subdirectories and files
    local contents
    contents=($(ls -A "$dir"))

    # Loop through the contents
    local count=${#contents[@]}
    for ((i = 0; i < count; i++)); do
        local item="${contents[$i]}"
        local new_prefix="${prefix}│   "
        local is_last=$((i == count - 1))

        if [ "$is_last" -eq 1 ]; then
            new_prefix="${prefix}    "
        fi

        local item_path="$dir/$item"
        if [ -d "$item_path" ]; then
            # Recursively call the function for subdirectories
            generate_tree "$item_path" "$new_prefix"
        else
            # Display files with size and modification date
            local file_size
            file_size=$(du -sh "$item_path" | awk '{print $1}')
            local mod_date
            mod_date=$(date -r "$item_path" "+%Y-%m-%d %H:%M:%S")
            # Display files with color
            echo -e "${file_color}${new_prefix}├── $item ($file_size, $mod_date)${reset_color}"
        fi
    done
}

# Function to display help information
display_help() {
    echo "Usage: $0 [OPTIONS] <directory_path>"
    echo "OPTIONS:"
    echo "  -h, --help       Display this help message"
    echo "  -d, --directories-only  Display directories only (no files)"
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            display_help
            exit 0
            ;;
        -d|--directories-only)
            directories_only=true
            shift
            ;;
        *)
            directory="$1"
            shift
            ;;
    esac
done

# Check if a directory path is provided as an argument
if [ -z "$directory" ]; then
    echo "Error: Directory path not provided. Use -h or --help for usage information."
    exit 1
fi

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' not found."
    exit 1
fi

# Print the directory tree starting with the provided directory
echo "Directory Tree for: $directory"
generate_tree "$directory" ""

# Optionally, display only directories (no files)
if [ "$directories_only" = true ]; then
    echo "Directories only:"
    find "$directory" -type d -print
fi
