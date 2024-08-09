#!/bin/bash

# Function to download a Google Drive file
download_drive_file() {
    local file_id="$1"
    local file_name="$2"

    echo "Downloading file with ID: $file_id"

    # Fetching the confirmation token required for downloading large files
    CONFIRM=$(wget --quiet --save-cookies cookies.txt --keep-session-cookies --no-check-certificate \
              "https://docs.google.com/uc?export=download&id=${file_id}" -O- | \
              sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')

    # Downloading the file with aria2c for parallel download
    aria2c --load-cookies=cookies.txt "https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${file_id}" \
           --out="${file_name}" \
           --split=16 --max-connection-per-server=16 --min-split-size=1M --max-concurrent-downloads=8

    # Clean up cookies
    rm -f cookies.txt
}

# Check if the necessary tools are installed
if ! command -v aria2c &> /dev/null; then
    echo "aria2c could not be found. Please install it to use this script."
    exit 1
fi

if ! command -v wget &> /dev/null; then
    echo "wget could not be found. Please install it to use this script."
    exit 1
fi

# Check for URL argument
if [ -z "$1" ]; then
    echo "Usage: $0 <google_drive_url>"
    exit 1
fi

# Extract the file ID and file name from the Google Drive URL
url="$1"
file_id=$(echo "$url" | grep -o '[-_a-zA-Z0-9]\{28,\}')
file_name="downloaded_file"

# Start the download process
download_drive_file "$file_id" "$file_name"
