#!/bin/bash

# User-friendly system cleanup script with advanced features

# Define directories and file extensions to clean
temp_dirs=("/tmp" "/var/tmp")
log_dirs=("/var/log")
file_extensions=("*.log" "*.tmp" "*.bak" "*.swp")

# Excluded directories (you can add more)
exclude_dirs=("/tmp/safe")

# Log file location
log_file="/var/log/system_cleanup.log"

# Function to display a confirmation prompt
confirm() {
  read -r -p "$1 (y/n): " response
  case "$response" in
    [yY][eE][sS]|[yY]) true ;;
    *) false ;;
  esac
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script requires root privileges. Please run it as root or using sudo."
  exit 1
fi

# Confirm with the user before cleaning
if ! confirm "Do you want to clean up temporary files, logs, and unnecessary data?"; then
  echo "Cleanup aborted."
  exit 0
fi

# Create or clear the log file
touch "$log_file"
echo "Cleanup started: $(date)" > "$log_file"

# Clean temporary directories
echo "Cleaning temporary directories..."
for dir in "${temp_dirs[@]}"; do
  if [ -d "$dir" ] && [[ ! " ${exclude_dirs[@]} " =~ " $dir " ]]; then
    find "$dir" -type f -name "${file_extensions[*]}" -exec rm -f {} + >> "$log_file" 2>&1
  fi
done

# Clean log directories
echo "Cleaning log directories..."
for dir in "${log_dirs[@]}"; do
  if [ -d "$dir" ] && [[ ! " ${exclude_dirs[@]} " =~ " $dir " ]]; then
    find "$dir" -type f -name "${file_extensions[*]}" -exec rm -f {} + >> "$log_file" 2>&1
  fi
done

# Clean package manager cache (optional)
echo "Cleaning package manager cache..."
if [ -x "$(command -v apt-get)" ]; then
  apt-get clean >> "$log_file" 2>&1
elif [ -x "$(command -v yum)" ]; then
  yum clean all >> "$log_file" 2>&1
fi

# Display the amount of freed space
echo "Disk space freed up:"
df -h

echo "Cleanup completed. Log file: $log_file"
