#!/bin/bash

#
#
#
#
#
#

# Transfers either a file or directory to the specified destination directory.
function transfer() {

    # Verify that two arguments were provided.
    if [ $# -ne 2 ]; then
        echo "Usage: transfer <source> <destination>"
    return 1
    fi

    local src=$1
    local dest=$2

    # Check if the source file/directory exists.
    if [ ! -e $src ]; then
        echo "Error: Source file/directory ("$src") does not exist"
        return 1
    fi

    # Extract the basename of the source file/directory
    local base=$(basename $src)

    # If the destination file/directory exists, delete it
    if [ -e "$dest/$base" ]; then
        rm -rf "$dest/$base"
    fi

    # Copy the source file/directory to the destination.
    cp -R $src $dest

    # Check the status of the copy operation.
    if [ $? -eq 0 ]; then
        echo "Transfer successful"
    else
        echo "Error: Transfer failed"
    fi
}

# Get the script's current directory
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fs_dir="${scripts_dir}/pic32fs"

# Check if the file system has been mounted yet.
if [ ! mountpoint -q "${fs_dir}" ]; then

    # Remove pic32fs directory if it exists and echo an error message how the user should use the mount command.
    if [ -d "${fs_dir}" ]; then

        rm -rf "${fs_dir}"
    fi

    echo "ERROR - The file system has not been mounted yet. Please run the mount command first."
    exit 1
fi

# Read flags from the command line and execute appropriately.

# Default to -p
flag="-p"

# Check if a flag was provided
if [ $# -gt 0 ]; then
    # Get the flag without the dash
    flag="$1"
fi

# Ensure only one flag is provided
if [ $# -gt 1 ]; then
    echo "ERROR - Too many arguments. Please provide only one flag."
    exit 1
fi

# Handle the flag with a case statement
case $flag in
    -g|--generated)
        # Check if the directories boot and lib exist in the generated directory.

        if [ ! -d "${scripts_dir}/../generated/boot" ] || [ ! -d "${scripts_dir}/../generated/lib" ]; then
            echo "ERROR - The generated directory does not contain the boot and lib directories. Please run the compile command first."
            exit 1
        fi

        # Transfer the boot and lib directories from the generated directory to the file system.

        transfer "${scripts_dir}/../generated/boot" "${fs_dir}"
        transfer "${scripts_dir}/../generated/lib/modules" "${fs_dir}/lib"

        ;;
    -p|--precompiled)
        # WARNING - this will assume that the boot and lib directories are in the precompiled directory.
        # Transfer the boot and lib directories from the precompiled directory to the file system.

        transfer "${scripts_dir}/../precompiled/boot" "${fs_dir}"
        transfer "${scripts_dir}/../precompiled/lib/modules" "${fs_dir}/lib"

        ;;
    *)
        echo "Error: Invalid flag. Please use -g or -p."
        exit 1
        ;;
esac

echo "Installation complete!"

exit 0
