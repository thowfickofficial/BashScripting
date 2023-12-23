#!/bin/bash

# Define the script name for usage messages
SCRIPT_NAME=$(basename "$0")

# Function to display usage information
usage() {
  cat <<EOM
Usage: $SCRIPT_NAME [OPTIONS] <directory> <pattern> <replacement>

OPTIONS:
  -r, --recursive     Recursively rename files in subdirectories.
  -i, --ignore-case   Perform case-insensitive pattern matching.
  -l, --log <file>    Log renaming operations to a file.
  -b, --backup        Create backups of original files.
  -d, --dry-run       Perform a dry run (preview without renaming).
  -h, --help          Show this help message and exit.

DESCRIPTION:
  This script renames files in a directory based on a specified pattern or rule.

ARGUMENTS:
  <directory>     The directory containing the files to be renamed.
  <pattern>       The pattern to search for in file names.
  <replacement>   The replacement pattern to use for renaming.

EXAMPLES:
  $SCRIPT_NAME /path/to/directory "old_pattern" "new_pattern"
  $SCRIPT_NAME -r -i /path/to/directory "old_pattern" "new_pattern"
  $SCRIPT_NAME -b -l rename_log.txt /path/to/directory "old_pattern" "new_pattern"
  $SCRIPT_NAME -d /path/to/directory "old_pattern" "new_pattern"

OPTIONS DETAILS:
  -r, --recursive:
    Recursively rename files in subdirectories of the specified directory.

  -i, --ignore-case:
    Perform case-insensitive pattern matching when searching for the pattern in file names.

  -l, --log <file>:
    Log renaming operations to the specified log file.

  -b, --backup:
    Create backups of original files before renaming. Backups will have a '.bak' extension.

  -d, --dry-run:
    Perform a dry run to preview renaming without actually renaming the files.

  -h, --help:
    Show this help message and exit.

NOTES:
  - The script uses regular expressions for pattern matching.
  - If a file name already matches the specified replacement pattern, it will not be renamed.
  - When using the --log option, existing log files will be appended, not overwritten.

EOM
  exit 1
}

# Initialize variables with default values
recursive=false
ignore_case=false
log_file=""
create_backup=false
dry_run=false

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -r|--recursive)
      recursive=true
      ;;
    -i|--ignore-case)
      ignore_case=true
      ;;
    -l|--log)
      log_file="$2"
      shift
      ;;
    -b|--backup)
      create_backup=true
      ;;
    -d|--dry-run)
      dry_run=true
      ;;
    -h|--help)
      usage
      ;;
    *)
      break
      ;;
  esac
  shift
done

# Check if the user provided the required arguments
if [ $# -lt 3 ]; then
  usage
fi

# Extract command-line arguments
directory="$1"
pattern="$2"
replacement="$3"

# Determine the find command options for recursion
find_options="-maxdepth 1"
if [ "$recursive" = true ]; then
  find_options=""
fi

# Determine the case sensitivity for pattern matching
if [ "$ignore_case" = true ]; then
  shopt -s nocasematch
fi

# Check if the directory exists
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' does not exist."
  exit 1
fi

# Change to the specified directory
cd "$directory" || exit

# Initialize the log file
if [ -n "$log_file" ]; then
  touch "$log_file" || exit
  echo "Renaming log ($(date)): " >> "$log_file"
fi

# Loop through files in the directory (and its subdirectories, if recursive)
find . $find_options -type f -print0 | while IFS= read -r -d $'\0' file; do
  # Get the file name without path
  filename="${file##*/}"

  # Check if the file matches the pattern
  if [[ "$filename" =~ $pattern ]]; then
    # Perform the rename using the replacement pattern
    new_name="${filename//$pattern/$replacement}"

    # Ensure the new name is not empty and different from the old name
    if [ -n "$new_name" ] && [ "$filename" != "$new_name" ]; then
      # Backup the original file
      if [ "$create_backup" = true ]; then
        cp "$file" "${file}.bak"
      fi

      # Log the renaming operation
      if [ -n "$log_file" ]; then
        echo "Renamed: $filename -> $new_name" >> "$log_file"
      fi

      # Perform the actual rename or display a preview
      if [ "$dry_run" = true ]; then
        echo "Preview: $filename -> $new_name"
      else
        mv "$file" "${file%/*}/$new_name"
        echo "Renamed: $filename -> $new_name"
      fi
    fi
  fi
done

# Reset case sensitivity option
if [ "$ignore_case" = true ]; then
  shopt -u nocasematch
fi

echo "File renaming complete."
