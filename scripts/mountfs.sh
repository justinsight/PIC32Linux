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

# Set the desired label
label="pic32fs"

# Check if blkid is installed
command -v blkid >/dev/null 2>&1 || { echo >&2 "Error: blkid command not found. Please install it and try again."; exit 1; }

echo "Attempting to mount MicroSD card with label '${label}'..."

# Find the device with the specified label
device=$(sudo blkid | grep "label=\"${label}\"" | grep -o -E "/dev/[^:]*")

if [ -z "$device" ]; then
  echo "Error: MicroSD card with label '${label}' not found. Please check if the card is plugged in correctly and try again."
  exit 1
fi

# Get the current script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create the mount point
mount_point="${script_dir}/pic32fs"
mkdir -p "${mount_point}"

# Check if the partition is already mounted
mounted=$(mount | grep -o "^${device}")

if [ ! -z "$mounted" ]; then
  echo "Warning: Partition ${device} is already mounted. Attempting to unmount first."
  sudo umount "${device}"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to unmount partition ${device}. Please unmount it manually and try again."
    exit 1
  fi
fi

# Mount the partition
sudo mount "${device}" "${mount_point}"
if [ $? -ne 0 ]; then
  echo "Error: Failed to mount partition ${device} to ${mount_point}."
  exit 1
fi

echo "Successfully mounted partition ${device} to ${mount_point}."
exit 0
