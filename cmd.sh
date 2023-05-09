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
#	./cmd.sh
#       Enter commands when prompted.
#
# Commands:
#
#	i, initialize-simple
#
#		* This will apply permissions for all scripts and download the premade and file system image.
#		* Should be run at the beginning before anything else.
#
#   I, initialize-advanced
#
#       * This will perform the same actions as the --initialize-simple flag, but will also download
#         the source code for the bootloader and kernel.
#              
#   L, list-all    
#
#       * This will list all files that are relevant if the user is seeking to make custom modifications
#         to the bootloader or kernel (say for remapping the UART pins).
#
#   c, compile <argument>
#       
#       * This will compile the bootloader or kernel depending on the argument provided.
#       * Valid arguments:
#               'b' for bootloader.
#               'k' for kernel.
#
# Author : Justin Newkirk
# Date   : May 8, 2023
# Project: Linux for PIC32.
#

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
    echo "  h, help                  Show all the available options."
    echo "  i, initialize-simple     Gives all scripts the proper permissions and downloads"
    echo "                           the premade file system image."
    echo "  I, initialize-advanced   Performs the same actions as the --initialize-simple flag,"
    echo "                           but also downloads the Kernel and Bootloader source code."
    echo "  L, list-all              Lists all relevant files that are needed for custom modifications."
    echo "  c, compile <argument>    Compile the bootloader or kernel."
    echo "                              Valid arguments:"
    echo "                                  'b' for bootloader"
    echo "                                  'k' for kernel."
    echo " exit, quit                Exit the terminal."
    echo
    echo "For more information, open this script in a text editor of your choice and read the header comments for each command."
    echo
}

# Script Logic ========================================================================================================

# Get the directory path to the initialization script.

scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/scripts"

# Process the command line arguments.

#!/bin/bash

# Display a welcome message
echo "Welcome to the PIC32Linux project terminal! Type 'exit' or 'quit' to leave."
echo "If you need help, type 'h' or 'help' for more information."
echo

while true; do
  # Display a prompt for user input
  echo -n "linux-pic32> "

  # Read a line of input from the user
  read user_input

# Skip to the next iteration if the user input is empty
  if [[ -z "$user_input" ]]; then
    continue
  fi

  # Exit the loop if the user types 'exit' or 'quit'
  if [[ "$user_input" == "exit" ]] || [[ "$user_input" == "quit" ]]; then
    break
  fi

  # Execute the user's input based on the command
  set -- $user_input
  case "$1" in
    h|help)
        display_help
        ;;
    -i|initialize-simple)

        # Run initialization script.
        "$scripts_dir"/initialize.sh
        ;;
    I|initialize-advanced)

        # Run initialization script.
        "$scripts_dir"/initialize.sh --all
        ;;
    L|list-all)

        # Run list script.
        "$scripts_dir"/list.sh --serial
        ;;
    c|compile)

        # Check if there is exactly one argument provided and exit with error if not.
        if [ $# -ne 2 ]; then
            error "Compile needs an additional argument. Use the h or help command for more information."
        fi

        # Read flags and execute.
        case "$2" in
            b)
                # Run bootloader compilation script.
                "$scripts_dir"/compile_bootloader.sh
                ;;
            k)
                # Run kernel compilation script.
                "$scripts_dir"/compile_kernel.sh
                ;;
            *)
                error "Invalid argument provided. Use the h or help command for more information."
                ;;
        esac
        ;;
    *)
        echo "Error: Unsupported argument $1" >&2
        display_help
        ;;
  esac
done

# Display a farewell message
echo "Goodbye!"
