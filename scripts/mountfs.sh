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
LABEL="pic32fs"

# Check if blkid is installed
command -v blkid >/dev/null 2>&1 || { echo >&2 "Error: blkid command not found. Please install it and try again."; exit 1; }

echo "Attempting to mount MicroSD card with label '${LABEL}'..."

# Find the device with the specified label
DEVICE=$(blkid | grep "LABEL=\"${LABEL}\"" | grep -o -E "/dev/[^:]*")

if [ -z "$DEVICE" ]; then
  echo "Error: MicroSD card with label '${LABEL}' not found. Please check if the card is plugged in correctly and try again."
  exit 1
fi

# Get the current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create the mount point
MOUNT_POINT="${SCRIPT_DIR}/pic32fs"
mkdir -p "${MOUNT_POINT}"

# Check if the partition is already mounted
MOUNTED=$(mount | grep -o "^${DEVICE}")

if [ ! -z "$MOUNTED" ]; then
  echo "Warning: Partition ${DEVICE} is already mounted. Attempting to unmount first."
  sudo umount "${DEVICE}"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to unmount partition ${DEVICE}. Please unmount it manually and try again."
    exit 1
  fi
fi

# Mount the partition
sudo mount "${DEVICE}" "${MOUNT_POINT}"
if [ $? -ne 0 ]; then
  echo "Error: Failed to mount partition ${DEVICE} to ${MOUNT_POINT}."
  exit 1
fi

echo "Successfully mounted partition ${DEVICE} to ${MOUNT_POINT}."
exit 0
