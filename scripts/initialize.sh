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

# An error function that takes in an error message, outputs to std_err and exits with error code 1.
error() {
    echo "ERROR - $1" >&2
    exit 1
}

# A function for modifying the bootloader source code to the working code for the PIC32 MZ DA Curiosity Board.
modify_bootloader() {

    echo "Modifying bootloader source code..."

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

# A function for modifying the kernel source code to the working code for the PIC32 MZ DA Curiosity Board.
modify_kernel(){

    echo "Modifying Kernel source code..."

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
#
# It will attempt to download the file system image three times
#
# Return: 1 if the download failed.
download_fs(){

    echo
    echo "==============================================================="
    echo
    echo "Downloading file system image..."
    echo

    # Go to the precompiled directory.

    cd "$script_dir"/../precompiled

    attempt=0
    download_successful=1

    while [ ! -f "$script_dir"/../precompiled/pic32fs-minimal.zip ] && [ $attempt -lt 3 ]; do

        attempt=$(( attempt + 1 ))

        # Display the attempt number if one attempt has already been made. 

        if [ $attempt -gt 1 ]; then

            echo "Attempt $attempt..."
        fi

        # Try to download the file system image.

        wget https://github.com/sergev/linux-pic32/releases/download/v1.1/pic32fs-minimal.zip

        download_successful=$?

        if [ ! -f "$script_dir"/../precompiled/pic32fs-minimal.zip ] || [ download_successful -ne 0 ]; then
            
            echo "Warning - File system image download failed..."
            echo "Removing partial download..."

            # Delete any of the partial downloads.

            rm pic32fs-minimal.zip
        fi
    done

    # If the download failed, then return 1.

    if [ download_successful -ne 0 ]; then

        return 1
    fi

    # Unzip the file system image.

    unzip pic32fs-minimal.zip
    rm *.zip
}

# A download function bootloader and kernel sources.
download_sources() {

    echo
    echo "==============================================================="

    # Initialize return value variable to 0.

    return_val=0

    # Check if bootloader source exists and download if not.
    if [ ! -d "$script_dir"/../bootloader/u-boot-pic32 ]; then
        
        echo
        echo "Downloading bootloader source..."
        echo
        
        # Go to the bootloader directory.

        cd "$script_dir"/../bootloader
        
        # Attempt to clone the directory three times, printing the attempt count if more than one attempt is made,
        # and set return value to 1 if the download failed.

        attempt=0
        download_successful=1

        while [ download_successful -ne 0 ] && [ $attempt -lt 3 ]; do

            attempt=$(( attempt + 1 ))

            if [ $attempt -gt 1 ]; then

                echo "Attempt $attempt..."
            fi

            git clone https://github.com/sergev/u-boot-pic32.git

            # Check if git returned an error.

            download_successful=$?

            if [ download_successful -ne 0 ]; then

                echo "Warning - Bootloader source download failed..."
                echo "Removing partial download..."

                # Delete the partial download.

                rm -r u-boot-pic32
            fi
        done

        # If the download_success variable is 0, then run the modify_bootloader function.
        # Otherwise, set the return value to 1.

        if [ download_successful -eq 0 ]; then

            # Update codebase with working code.
            modify_bootloader
        else

            return_val=1
        fi
    else

        echo "Bootloader source already exists. Skipping download."
    fi

    # Check if kernel source exists and download if not.
    if [ ! -d "$script_dir"/../kernel/linux-pic32 ]; then
        
        echo
        echo "Downloading kernel source..."
        echo

        # Go to the kernel directory.

        cd "$script_dir"/../kernel

        # Attempt to clone the directory three times, printing the attempt count if more than one attempt is made,
        # and set return value to 1 if the download failed.

        attempt=0
        download_successful=1

        while [ download_successful -ne 0 ] && [ $attempt -lt 3 ]; do

            attempt=$(( attempt + 1 ))

            if [ $attempt -gt 1 ]; then

                echo "Attempt $attempt..."
            fi

            git clone https://github.com/sergev/linux-pic32.git
        
            download_successful=$?

            if [ download_successful -ne 0 ]; then

                echo "Warning - Bootloader source download failed..."
                echo "Removing partial download..."

                # Delete the partial download.

                rm -r linux-pic32
            fi
        done

        # If the download_success variable is 0, then run the modify_bootloader function.
        # Otherwise, set the return value to 1.

        if [ download_successful -eq 0 ]; then

            # Update codebase with working code.
            modify_kernel
        else

            return_val=$((return_val + 2))
        fi
    else
    
        echo "Kernel source already exists. Skipping download."
    fi

    # Return the return value.

    return $return_val
}

# Script Logic ========================================================================================================


# Get the directory path to the initialization script.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Initialization finished message.

initialize_finish=""

# Initialize the failure value to false.

failure=false

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

    # Check (with a switch) return values (ranging from 0 to 3) to tell which or both downloads failed.

    case $? in
        1)
            echo "ERROR - Bootloader source download failed. Please run the advanced initialization command again."
            failure=true
            ;;
        2)
            echo "ERROR - Kernel source download failed. Please run the advanced initialization command again."
            failure=true
            ;;
        3)
            echo "ERROR - Bootloader and kernel source download failed. Please run the advanced initialization command again."
            failure=true
            ;;
        *)
            echo "Bootloader and kernel source download successful."
            ;;
    esac

    initialize_finish="Advanced"
else
    initialize_finish="Simple"
fi

# Give all the scripts the proper permissions.

chmod +rwx "$script_dir"/*.sh

# Install relevant pieces of software.

echo "Installing relevant software..."
echo
sudo apt-get install gcc-mipsel-linux-gnu srecord gzip make git wget unzip

# Download the pic32fs image if it doesn't already exist. (Very expensive download.)

if [ ! -f "$script_dir"/../precompiled/pic32fs.img ]; then
        
    download_fs

    # Check if the download was successful.

    if [ $? -ne 0 ]; then

        echo "ERROR - File system image download failed. Please run the initialization command again."
        failure=true
    fi
else

    echo "File system image already exists. Skipping download."
fi

# If the failure variable is true, then exit with error.

if [ "$failure" = true ]; then

    echo
    echo "ERROR - Initialization encountered errors. Please run the initialization command again."
    echo

    exit 1
fi

# Display the initialization finished message.

echo "$initialize_finish initialization complete."
echo