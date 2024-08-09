#!/bin/bash

# Check if the necessary tools are installed
if ! command -v gdown &> /dev/null; then
    echo "gdown could not be found. Please install it to use this script."
    exit 1
fi

# Check for folder URL argument
if [ -z "$1" ]; then
    echo "Usage: $0 <google_drive_folder_url>"
    exit 1
fi

# Extract the folder ID from the Google Drive URL
url="$1"
folder_id=$(echo "$url" | grep -o '[-_a-zA-Z0-9]\{28,\}')

# Download the entire folder using gdown, including remaining files after the first 50
echo "Downloading entire folder..."
gdown --folder --id "$folder_id" --remaining-ok

echo "Download completed."
