#!/bin/bash

# Default configuration values
source_dir=""
destination_dir=""
retention_policy=7
gpg_recipient=""
email_notification=""

# Function to display script usage
usage() {
  echo "Usage: $(basename "$0") -s SOURCE_DIR -d DEST_DIR [-r RETENTION] [-g GPG_RECIPIENT] [-e EMAIL]"
  echo "Options:"
  echo "  -s SOURCE_DIR     Source directory to be backed up."
  echo "  -d DEST_DIR       Destination directory where backups will be stored."
  echo "  -r RETENTION      Retention policy (number of backups to keep, default is 7)."
  echo "  -g GPG_RECIPIENT  GPG recipient for encryption (optional)."
  echo "  -e EMAIL          Email address for backup notifications (optional)."
  exit 1
}

# Process command-line options
while getopts ":s:d:r:g:e:" opt; do
  case $opt in
    s)
      source_dir="$OPTARG"
      ;;
    d)
      destination_dir="$OPTARG"
      ;;
    r)
      retention_policy="$OPTARG"
      ;;
    g)
      gpg_recipient="$OPTARG"
      ;;
    e)
      email_notification="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      usage
      ;;
  esac
done

# Check if required options are provided
if [[ -z $source_dir || -z $destination_dir ]]; then
  echo "Error: Source and destination directories are required."
  usage
fi

# Check if the source directory exists
if [ ! -d "$source_dir" ]; then
  echo "Source directory does not exist. Please provide a valid source directory."
  exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$destination_dir" ]; then
  mkdir -p "$destination_dir"
fi

# ... Rest of the script (same as previous versions) ...

# Use rsync to perform the backup
rsync -av --delete "$backup_archive.gpg" "$destination_dir/"

# Display a message when the backup is completed
echo "Backup completed successfully. Log file: $log_file"

# Remove old backups
remove_old_backups

# Send email notification if an email address is provided
if [ -n "$email_notification" ]; then
  echo "Backup completed successfully. Log file: $log_file" | mail -s "Backup Completed" "$email_notification"
fi
