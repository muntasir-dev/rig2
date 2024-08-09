#!/bin/bash

# Function to download files using aria2c
download_file() {
    local file_id="$1"
    local file_name="$2"
    echo "Downloading: $file_name"
    aria2c --load-cookies=cookies.txt \
           "https://docs.google.com/uc?export=download&id=${file_id}" \
           --out="${file_name}" \
           --split=16 --max-connection-per-server=16 --min-split-size=1M --max-concurrent-downloads=8
}

# Check if the necessary tools are installed
if ! command -v gdown &> /dev/null; then
    echo "gdown could not be found. Please install it to use this script."
    exit 1
fi

if ! command -v aria2c &> /dev/null; then
    echo "aria2c could not be found. Please install it to use this script."
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

# Get the list of files in the folder
echo "Fetching list of files in folder..."
gdown --folder --id "$folder_id" --dry-run > file_list.txt

# Download each file listed by gdown
while IFS= read -r line; do
    # Extract the file ID and name
    file_id=$(echo "$line" | grep -o '[-_a-zA-Z0-9]\{28,\}')
    file_name=$(echo "$line" | grep -oP '(?<=Saving to: ).*')

    # Download the file
    download_file "$file_id" "$file_name"
done < <(grep "gdown" file_list.txt)

# Clean up
rm -f cookies.txt file_list.txt
