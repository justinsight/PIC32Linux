#!/bin/bash

#
# This script scans for the MicroSD card that has the pic32fs label and mounts it to the pic32fs directory.
# This is useful for accessing the file system image which we need in order
# make and install the new Kernel and Modules after compilation.
#
# Author : Justin Newkirk
# Date   : May 10, 2023
# Project: Linux for PIC32
#

# Function definitions =================================================================================================

# This function will mount the MicroSD card with the pic32fs label to the pic32fs directory.
function mountfs(){

    # Set the desired label
    label="pic32fs"

    # Check if blkid is installed
    command -v blkid >/dev/null 2>&1 || { echo >&2 "ERROR - blkid command not found. Please install it and try again."; exit 1; }

    echo "Attempting to mount MicroSD card with label '${label}'..."

    # Find the device with the specified label
    device=$(sudo blkid | grep "label=\"${label}\"" | grep -o -E "/dev/[^:]*")

    if [ -z "$device" ]; then
        echo "ERROR - MicroSD card with label '${label}' not found. Please check if the card is plugged in correctly and try again."
        exit 1
    fi

    # Create the mount point
    mount_point="${script_dir}/pic32fs"
    mkdir -p "${mount_point}"

    # Check if the partition is already mounted
    mounted=$(mount | grep -o "^${device}")

    if [ ! -z "$mounted" ]; then

        echo "Warning: Partition ${device} is already mounted. Attempting to unmount first."
        sudo umount "${device}"

        if [ $? -ne 0 ]; then
            echo "ERROR - Failed to unmount partition ${device}. Please unmount it manually and try again."
            exit 1
        fi
    fi

    # Mount the partition
    sudo mount "${device}" "${mount_point}"
    if [ $? -ne 0 ]; then

        echo "ERROR - Failed to mount partition ${device} to ${mount_point}."
        exit 1
    fi
}

# This function will unmount the MicroSD card with the pic32fs label from the pic32fs directory.
function unmountfs(){

    # Check if the file system has been mounted yet.
    if [ mountpoint -q "${fs_dir}" ]; then

        sudo umount "${fs_dir}"
        rm -rf "${fs_dir}"
    else

        echo "ERROR - The file system has not been mounted yet. Please run the mount command first."
        exit 1
    fi
}


# Script Logic ========================================================================================================

# Get the script's current directory
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fs_dir="${scripts_dir}/pic32fs"

# Default to -p
flag="-m"

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
    -m|--mount)
        
        mountfs
        ;;
    -u|--unmount)

        unmountfs
        ;;
    *)
        echo "ERROR - Invalid flag. Please use -g or -p."
        exit 1
        ;;
esac

exit 0
