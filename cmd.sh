#!/bin/bash

#
# This script will facilitate nearly all actions that the user would like to perform
# with respect to preparing and installing Linux on the PIC32 MZ DA Curiosity board.
#
# This script will provide the following functionality:
#
#	* Install all relevent tools that are needed for compilation
#	  and related actions.
#
#	* Install the custom Kernel to the provided file system.
#
#	* Very quickly access relevant files that needed to be changed.
#	  as well as shortcuts to those files depending on what modifications
#	  are being attempted.
#
#	* Compile Boot Loader and Kernel.
#
#	* Reset changes made to either the boot loader source files, kernel source files, or both.
#
#		* WARNING - Only the predetermined files (found with ./cmd --list-relevant) will be reset.
#
#
# Usage:
#
#	./cmd <flag> <argument if needed>
#
# Flags:
#
#	-i --initialize-simple
#
#		* This will apply permissions for all scripts and download the premade and file system image.
#		* Should be run at the beginning before anything else.
#
#   -I --initialize-advanced
#
#       * This will perform the same actions as the --initialize-simple flag, but will also download
#         the source code for the bootloader and kernel.
#              
#   -L --list-all    
#
#       * This will list all files that are relevant if the user is seeking to make custom modifications
#         to the bootloader or kernel (say for remapping the UART pins).
#
# Author : Justin Newkirk
# Date   : May 8, 2023
# Project: Linux for PIC32.
#

# Get the directory path to the initialization script.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"





# Function definitions =================================================================================================


# An error function that takes in an error message, outputs to std_err and exits with error code 1.
error() {
    echo "ERROR - $1" >&2
    exit 1
}



# A help function that displays all the available commands for this script.

function display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Available options:"
    echo "  -h, --help                  Show all the available options."
    echo "  -i, --initialize-simple     Gives all scripts the proper permissions and downloads"
    echo "                              the premade file system image."
    echo "  -I. --initialize-advanced   Performs the same actions as the --initialize-simple flag,"
    echo "                              but also downloads the Kernel and Bootloader source code."
    echo "  -L --list-all               Specify a directory to process"
    echo
    echo "For more information, open this script in a text editor of your choice and read the header comments for each command."
    echo
}