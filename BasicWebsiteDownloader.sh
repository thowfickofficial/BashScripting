#!/bin/bash

# Default settings
OUTPUT_DIR="downloaded_website"
RECURSIVE_DEPTH=5  # Maximum recursion depth
USER_AGENT="Mozilla/5.0 (Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0"  # User-Agent for wget

# Function to display usage information
usage() {
  echo "Usage: $0 [options] <URL>"
  echo "Options:"
  echo "  -o <directory>  Output directory (default: $OUTPUT_DIR)"
  echo "  -d <depth>      Maximum recursion depth (default: $RECURSIVE_DEPTH)"
  echo "  -u <user-agent> User-Agent for wget (default: '$USER_AGENT')"
  exit 1
}

# Parse command-line options
while getopts ":o:d:u:" opt; do
  case "$opt" in
    o) OUTPUT_DIR="$OPTARG";;
    d) RECURSIVE_DEPTH="$OPTARG";;
    u) USER_AGENT="$OPTARG";;
    \?) echo "Invalid option: -$OPTARG" >&2; usage;;
  esac
done
shift $((OPTIND-1))

# Check for the URL argument
if [ $# -eq 0 ]; then
  echo "Error: Please provide a URL."
  usage
fi

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Define the URL
URL="$1"

# Download the webpage and resources
wget -P "$OUTPUT_DIR" --recursive --level="$RECURSIVE_DEPTH" --convert-links --backup-converted --adjust-extension --user-agent="$USER_AGENT" "$URL"

# Done
echo "Website downloaded to $OUTPUT_DIR"
