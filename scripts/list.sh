#!/bin/bash

#
# This script will provide the user the ability to list all relevant files that need to be modified for
# customizing the bootloader or kernel source code to operate with different hardware configurations.
#
# This will currently only list the files that need to be modified for remapping the UART pins.
#
# Usage:
#
#   ./list.sh <flag> <>
#
# Flags:
#
#  -s --serial
#
#       * This will list all files that need to be modified for remapping the UART pins for serial communcation.
#
# Author : Justin Newkirk
# Date   : May 9, 2023
# Project: Linux for PIC32
#

# Get the directory path to the initialization script.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"



# Check if there is exactly one argument provided and exit with error if not.

if [ $# -ne 1 ]; then

    error "Need exactly one argument. Use the -h or --help flag for more information."
fi

# Read flags and execute.

case "$1" in

    -h|--help)
        display_help
        exit 0
        ;;
    -s|--serial)
        list_serial
        exit 0
        ;;
    *)
        error "Invalid flag provided. Use the -h or --help flag for more information."
        ;;

esac


# Function definitions =================================================================================================


# An error function that takes in an error message, outputs to std_err and exits with error code 1.
error() {
    echo "ERROR - $1" >&2
    exit 1
}