#!/bin/bash

#
# This will install all relevant software for compilation, apply permissions for all scripts,
# download the premade file system image, and download the source code for the bootloader and kernel.
#
#
# Author : Justin Newkirk
# Date   : May 8, 2023
# Project: Linux for PIC32
#

# Get the directory path to the initialization script.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Check if there is more than one argument provided and exit with error if so.

if [ $# -gt 1 ]; then

    error "Too many arguments provided."
fi

# If there is one flag provided, then check if it is the -a or --all flag and exit with error if not.

if [ $# -eq 1 ]; then
    if [ "$1" != "-a" ] && [ "$1" != "--all" ]; then
    
        error "Invalid flag provided. Valid flags are '-a' or '--all'."
    fi

    # Download the bootloader and kernel source code.

    download_sources
fi

# Give all the scripts the proper permissions.

chmod +rwx "$script_dir"/*.sh

# Install relevant pieces of software.

sudo apt-get install gcc-mipsel-linux-gnu srecord gzip make git wget unzip

# Download the pic32fs image if it doesn't already exist. (Very expensive download.)

if [ ! -f "$script_dir"/../precompiled/pic32fs.img ]; then
        
    download_fs
else

    echo "File system image already exists. Skipping download."
fi


# Function definitions =================================================================================================

# A download function bootloader and kernel sources.
download_sources() {

    echo "==============================================================="
    echo "Downloading bootloader source..."
    cd "$script_dir"/../bootloader
    git clone https://github.com/sergev/u-boot-pic32.git

    echo "==============================================================="
    echo "Downloading kernel source..."
    cd "$script_dir"/../kernel
    git clone https://github.com/sergev/linux-pic32.git
}

# A download function for the file system image.
download_fs(){

    echo "==============================================================="
    echo "Downloading file system image..."
    cd "script_dir"/../precompiled
    wget https://github.com/sergev/linux-pic32/releases/download/v1.1/pic32fs-minimal.zip
    unzip pic32fs-minimal.zip
    rm *.zip
}

# An error function that takes in an error message, outputs to std_err and exits with error code 1.
error() {
    echo "ERROR - $1" >&2
    exit 1
}