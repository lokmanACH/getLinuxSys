#!/bin/bash

# Prompt the user to enter a system command
echo "Please enter a system command (e.g., node, python):"
read name

# Get the path of the command
sysPath=$(which "$name")

if [ -z "$sysPath" ]; then
    echo "Command '$name' not found!"
    exit 1
fi

# Prompt for output directory
echo "Enter the output directory (default: ./${name}_dependencies):"
read output_dir
output_dir="${output_dir:-${name}_dependencies}"

# Create the main output directory and subdirectories
mkdir -p "$output_dir/bin"
mkdir -p "$output_dir/dependencies"
mkdir -p "$output_dir/paths"
mkdir -p "$output_dir/bin_path"

# Create the paths file
path_file="$output_dir/paths/paths.txt"
touch "$path_file"

# Create the bin_path.txt file and write the command path
bin_path_file="$output_dir/bin_path/bin_path.txt"
echo "$sysPath" > "$bin_path_file"
echo "Bin path for command '$name' written to: $bin_path_file"

# Copy the main command binary
cp "$sysPath" "$output_dir/bin/"
if [ $? -eq 0 ]; then
    echo "Copied: $sysPath to $output_dir/bin/"
else
    echo "Failed to copy $sysPath"
    exit 1
fi

# Get the dependencies of the command
sysFiles=$(ldd "$sysPath")

# Print only the paths of the dependencies, copy each file, and write paths to the file
echo "$sysFiles" | awk '/=>/ {print $3} /ld-linux/ {print $1}' | while read -r file; do
    if [ -f "$file" ]; then
        cp "$file" "$output_dir/dependencies/"
        if [ $? -eq 0 ]; then
            echo "Copied: $file to $output_dir/dependencies/"
            echo "$file" >> "$path_file"  # Write the path to the paths file
        else
            echo "Failed to copy: $file"
        fi
    else
        echo "File not found: $file"
    fi
done

# Output the paths file location
echo "Paths of dependencies have been written to: $path_file"
echo "All files have been copied to: $output_dir"
