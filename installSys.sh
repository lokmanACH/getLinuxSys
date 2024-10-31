#!/bin/bash

# Prompt the user for the directory containing the paths, dependencies, and bin_path folders
echo "Please enter the path to the directory containing 'paths', 'dependencies', and 'bin_path' folders:"
read base_dir

# Check if the base directory exists
if [ ! -d "$base_dir" ]; then
    echo "Directory '$base_dir' does not exist!"
    exit 1
fi

# Define the paths to the files and directories
paths_file="$base_dir/paths/paths.txt"
bin_path_file="$base_dir/bin_path/bin_path.txt"
dependencies_dir="$base_dir/dependencies"
bin_dir="$base_dir/bin"

# Check if the paths.txt file exists
if [ ! -f "$paths_file" ]; then
    echo "File '$paths_file' does not exist!"
    exit 1
fi

# Check if the bin_path.txt file exists
if [ ! -f "$bin_path_file" ]; then
    echo "File '$bin_path_file' does not exist!"
    exit 1
fi

# Read the paths from the paths.txt file and check their existence
echo "Checking paths from '$paths_file':"
while IFS= read -r path; do
    if [ -e "$path" ]; then
        echo "Path '$path' exists."
    else
        echo "Path '$path' does not exist."
        
        # Extract the target directory and filename
        target_dir=$(dirname "$path")
        target_file=$(basename "$path")
        source_file="$dependencies_dir/$target_file"

        if [ -f "$source_file" ]; then
            # Create the target directory if it does not exist
            mkdir -p "$target_dir"
            
            # Attempt to copy with sudo
            echo "Attempting to copy '$source_file' to '$target_dir/$target_file'..."
            sudo cp "$source_file" "$target_dir/"
            if [ $? -eq 0 ]; then
                echo "Copied '$source_file' to '$target_dir/$target_file'."
            else
                echo "Failed to copy '$source_file' to '$target_dir/$target_file'."
            fi
        else
            echo "Source file '$source_file' does not exist in the dependencies folder."
        fi
    fi
done < "$paths_file"

# Check the bin path from bin_path.txt
echo "Checking bin path from '$bin_path_file':"
while IFS= read -r bin_path; do
    # Check if the bin path exists
    if [ -e "$bin_path" ]; then
        echo "Bin path '$bin_path' exists."
    else
        echo "Bin path '$bin_path' does not exist."
        
        # Extract the target directory and filename
        bin_target_dir=$(dirname "$bin_path")
        bin_target_file=$(basename "$bin_path")
        bin_source_file="$bin_dir/$bin_target_file"

        # Create the target directory if it does not exist
        mkdir -p "$bin_target_dir"
    fi

    # Attempt to copy the bin file
    if [ -f "$bin_source_file" ]; then
        # Attempt to copy with sudo
        echo "Attempting to copy '$bin_source_file' to '$bin_target_dir/$bin_target_file'..."
        sudo cp "$bin_source_file" "$bin_target_dir/"
        if [ $? -eq 0 ]; then
            echo "Copied '$bin_source_file' to '$bin_target_dir/$bin_target_file'."
        else
            echo "Failed to copy '$bin_source_file' to '$bin_target_dir/$bin_target_file'."
        fi
    else
        echo "Source file '$bin_source_file' does not exist in the bin folder."
    fi
done < "$bin_path_file"
