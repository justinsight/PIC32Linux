#!/bin/bash

#
# This will install all relevant software for compilation, apply permissions for all scripts,
# download the premade file system image, and download the source code for the bootloader and kernel.
#
# Usage:
#   ./initialize.sh <flag>
#
# Flags:
#
#   -a --all
#
#       * This will download the source code for the bootloader and kernel.
#
# Author : Justin Newkirk
# Date   : May 8, 2023
# Project: Linux for PIC32
#

# Function definitions =================================================================================================

# A function for modifying the bootloader source code to the working code for the PIC32 MZ DA Curiosity Board.
modify_bootloader() {

    echo "Modify bootloader source code..."

    # Remove old original files.

    rm  "$script_dir"/../bootloader/u-boot-pic32/board/microchip/pic32mzda/pic32mzda.c \
        "$script_dir"/../bootloader/u-boot-pic32/arch/mips/include/asm/arch-pic32/pic32.h \
        "$script_dir"/../bootloader/u-boot-pic32/include/configs/pic32mzdask.h

    # Replace original files with the working ones.

    cp  "$script_dir"/../precompiled/modified/bootloader_serial/pic32mzda.c \
        "$script_dir"/../bootloader/u-boot-pic32/board/microchip/pic32mzda/

    cp  "$script_dir"/../precompiled/modified/bootloader_serial/pic32.h \
        "$script_dir"/../bootloader/u-boot-pic32/arch/mips/include/asm/arch-pic32/

    cp  "$script_dir"/../precompiled/modified/bootloader_serial/pic32mzdask.h \
        "$script_dir"/../bootloader/u-boot-pic32/include/configs/
}

# a function for modifying the kernel source code to the working code for the PIC32 MZ DA Curiosity Board.
modify_kernel(){

    echo "Modify Kernel source code..."

    # Remove old original files.

    rm  "$script_dir"/../kernel/linux-pic32/arch/mips/pic32/pic32mzda/early_console.c \
        "$script_dir"/../kernel/linux-pic32/arch/mips/boot/dts/pic32/pic32mzda_sk.dts

    # Replace original files with the working ones.

    cp  "$script_dir"/../precompiled/modified/kernel_serial/early_console.c \
        "$script_dir"/../kernel/linux-pic32/arch/mips/pic32/pic32mzda/

    cp  "$script_dir"/../precompiled/modified/kernel_serial/pic32mzda_sk.dts \
        "$script_dir"/../kernel/linux-pic32/arch/mips/boot/dts/pic32/
}

# A download function for the file system image.
download_fs(){

    echo
    echo "==============================================================="
    echo
    echo "Downloading file system image..."
    echo

    cd "$script_dir"/../precompiled
    wget https://github.com/sergev/linux-pic32/releases/download/v1.1/pic32fs-minimal.zip
    unzip pic32fs-minimal.zip
    rm *.zip
}

# An error function that takes in an error message, outputs to std_err and exits with error code 1.
error() {
    echo "ERROR - $1" >&2
    exit 1
}

# A download function bootloader and kernel sources.
download_sources() {

    echo
    echo "==============================================================="

    # Check if bootloader source exists and download if not.
    if [ ! -d "$script_dir"/../bootloader/u-boot-pic32 ]; then
        
        echo
        echo "Downloading bootloader source..."
        echo
        
        cd "$script_dir"/../bootloader
        git clone https://github.com/sergev/u-boot-pic32.git

        # Update codebase with working code.

        modify_bootloader
    else

        echo "Bootloader source already exists. Skipping download."
    fi

    # Check if kernel source exists and download if not.
    if [ ! -d "$script_dir"/../kernel/linux-pic32 ]; then
        
        echo
        echo "Downloading kernel source..."
        echo
        
        cd "$script_dir"/../kernel
        git clone https://github.com/sergev/linux-pic32.git

        # Update codebase with working code.

        modify_kernel
    else
    
        echo "Kernel source already exists. Skipping download."
    fi
}

# Script Logic ========================================================================================================


# Get the directory path to the initialization script.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Initialization finished message.

initialize_finish=""

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

    initialize_finish="Advanced"
else
    initialize_finish="Simple"
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

# Display the initialization finished message.

echo "$initialize_finish initialization complete."
echo