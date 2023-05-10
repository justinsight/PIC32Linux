#!/bin/bash

#
#
#
#
#
#

# Get the script's current directory
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/scripts"

# Check if the 'pic32fs' directory exists in the current directory
if [ ! -d "${scripts_dir}/pic32fs" ]; then

    echo "Error: The 'pic32fs' directory does not exist in the current directory. Please mount the device at the script's current directory."
    exit 1
fi

# Check if the 'pic32fs' directory is a mount point
if mountpoint -q "${scripts_dir}/pic32fs"; then
    echo "Device is mounted at ${scripts_dir}/pic32fs."

    # Add your next block of code here
else
    echo "Error: The 'pic32fs' directory exists, but it's not a mount point. Please mount the device properly."
    exit 1
fi
else

fi
