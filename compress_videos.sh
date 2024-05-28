#!/bin/bash

# Ensure a file path is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 file_path"
    exit 1
fi

# File to process
input_file="$1"

# Directory structure
originals_dir="originals"

# Create the originals directory if it doesn't exist
mkdir -p "$originals_dir"

# Enable case-insensitive filename matching
shopt -s nocaseglob

# Process the provided file
if [ -e "$input_file" ]; then
    # Get the directory and base name of the file (without extension)
    file_dir=$(dirname "$input_file")
    base_name=$(basename "$input_file")
    # Remove the extension from the base name
    extension="${base_name##*.}"
    base_name="${base_name%.*}"
    
    # Move the original file to the originals directory, maintaining subdirectory structure
    original_file="$originals_dir/$file_dir/$base_name.$extension"
    mkdir -p "$(dirname "$original_file")"
    mv "$input_file" "$original_file"
    
    # Set the output file path
    output_file="$file_dir/$base_name.$extension"
    
    # If the output file already exists, append a suffix to avoid name conflict
    if [ -e "$output_file" ]; then
        output_file="$file_dir/$base_name-compressed.$extension"
    fi
    
    # Execute the ffmpeg command
    ffmpeg -i "$original_file" -vcodec libx264 -crf 28 -preset fast -acodec copy -movflags use_metadata_tags -map_metadata 0 -map_chapters 0 "$output_file"
fi

# Disable case-insensitive filename matching
shopt -u nocaseglob