#!/bin/bash

#
#
#
#
#

# Function definitions =================================================================================================

# Get's verification from the user before continuing.
function verify(){
    echo "WARNING: $1"
    echo "Are you sure you want to continue? (y/n)"

    # Read a line of input from the user
    read user_input

    # Exit the script if the user types 'n' or 'no'
    if [[ "$user_input" == "n" ]] || [[ "$user_input" == "no" ]]; then
        exit 1
    fi

    # Check if the user typed 'y' or 'yes' and leave if not with an error message.
    if [[ "$user_input" != "y" ]] && [[ "$user_input" != "yes" ]]; then
        echo "ERROR - Invalid input"
        exit 1
    fi

    # User has verified that they want to continue.

    return 0
}

# Deletes the bootloader and kernel source code directories.
function delete_sources(){

    # Delete the bootloader and kernel source code directories.

    echo "Deleting bootloader and kernel source code directories..."

    # Check if the bootloader source code directory exists and delete it if it does.
    if [ -d "${scripts_dir}/../bootloader/u-boot-pic32" ]; then
        rm -rf "${scripts_dir}/../bootloader/u-boot-pic32"
    fi

    # Check if the kernel source code directory exists and delete it if it does.
    if [ -d "${scripts_dir}/../kernel/linux-pic32" ]; then
        rm -rf "${scripts_dir}/../kernel/linux-pic32"
    fi

    echo "Bootloader and kernel source code directories deleted."

    return 0
}

# Deletes everything from the generated directory, thereby deleting the bootloader, kernel, and bootloader compilations.
function delete_generated(){

    # Delete everything from the generated directory.

    echo "Deleting generated kernel and bootloader files..."

    # Check if the generated directory exists and delete it if it does.
    if [ -d "${scripts_dir}/../generated" ]; then
        rm -rf "${scripts_dir}/../generated/*"
    fi

    echo "Generated files deleted."

    return 0
}

function delete_filesystem_image(){

    # Delete the pic32fs.img if it exists.

    echo "Deleting pic32fs.img..."

    # Check if the pic32fs directory exists and delete it if it does.
    if [ -f "${scripts_dir}/../precompiled/pic32fs.img" ]; then
        rm -rf "${scripts_dir}/../precompiled/pic32fs.img"
    fi

    echo "pic32fs.img deleted."

    return 0
}

# This function will return the modified kernel files back to the originals that came with the repository.
function restore_kernel_files(){
	
	# Copy the files from the "original" directory to the "kernel_serial" directory.
	kernel_serial_dir="${scripts_dir}/../precompiled/modified/kernel_serial/"
	sudo cp "${kernel_serial_dir}original/*" "${kernel_serial_dir}" 
}


# This function will return the modified bootloader files back to the originals that came with the repository.
function restore_bootloader_files(){
	
	# Copy the files from the "original" directory to the "kernel_serial" directory.
	bootloader_serial_dir="${scripts_dir}/../precompiled/modified/bootloader_serial/"
	sudo cp "${bootloader_serial_dir}original/*" "${bootloader_serial_dir}" 
}

# Script Logic ========================================================================================================

# Get the script directory.

scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if a flag was provided and return an error if not.
if [ $# -eq 0 ]; then

    echo "ERROR - No flag provided. Please provide a flag."
    exit 1
fi

# Ensure only one flag is provided
if [ $# -gt 1 ]; then
    echo "Error: Too many arguments. Please provide only one flag."
    exit 1
fi

# Handle the flag with a case statement
case $1 in
    -k|--modified-kernel-files)
	    # Restore the modified kernel files (that the user touched) to the original that came with repository.

	    restore_kernel_files
	    ;;
	    
    -b|--modified-bootloader-files)
	    # Restore the modified kernel files (that the user touched) to the original that came with repository.

	    restore_bootloader_files
	    ;;
    -g|--generated)
        # Delete the generated files.

        delete_generated
        ;;
    -s|--sources)
        # Verify with the user that they want to delete the source code directories.

        verify "This will delete the bootloader and kernel source code directories. This will not delete the generated files. Are you sure you want to continue?"

        # Delete the source code directories.

        delete_sources
        ;;
    -a|--all)
        # Verify with the user that they want to delete everything.

        verify "This will delete the bootloader and kernel source code directories as well as the generated files. Are you sure you want to continue?"
        
        delete_generated
        delete_sources
        delete_filesystem_image
        ;;
    *)
        echo "Error: Invalid flag. Please reference 'h' or 'help' for the available flags."
        exit 1
        ;;
esac

exit 0
