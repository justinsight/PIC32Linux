#!/bin/bash

#
# This script will facilitate nearly all actions that the user would like to perform
# with respect to preparing and installing Linux on the PIC32 MZ DA Curiosity board.
#
# This script will provide the following functionality:
#
#   * Behave like a terminal.
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
#	* etc. See the help command for more information.
#
# Usage:
#
#	./cmd.sh    Enter commands when prompted.
#
# Commands:
#   h, help     Show all the available commands.
#
# Author : Justin Newkirk
# Date   : May 8, 2023
# Project: Linux for PIC32.
#

# Function definitions =================================================================================================

# An error function that takes in an error message, outputs to std_err and exits with error code 1.

error() {
    echo "ERROR - $1" >&2
}

# A help function that displays all the available commands for this script.

function display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Available options:"
    echo "  h, help                 Show all the available options."
    echo "  i, initialize-simple    Gives all scripts the proper permissions and downloads"
    echo "                           the premade file system image."
    echo "  I, initialize-advanced  Performs the same actions as the --initialize-simple flag,"
    echo "                           but also downloads the Kernel and Bootloader source code."
    echo "  L, list-all              Lists all relevant files that are needed for custom modifications."
    echo "  c, compile <argument>   Compile the bootloader or kernel."
    echo "                              Valid arguments:"
    echo "                                  '-b' for bootloader"
    echo "                                  '-k' for kernel."
    echo "  m, mountfs              Mount the pic32fs so changes can be made to it."
    echo "  u, unmountfs            Unmount the pic32fs so it can be used to boot the board."
    echo "  p, install-precompiled  Install the precompiled kernel and modules to the pic32fs."
    echo "  g, install-generated    Install the generated kernel and modules to the pic32fs."
    echo "  reset                   Delete all kernel/bootloader source files pic32fs image."
    echo "                              Valid arguments:"
    echo "                                  '-g' for generated (compiled) files."
    echo "                                  '-s' for source code directories."
    echo "                                  '-a' for all of the above and including the pic32fs image."
    echo "  exit, quit              Exit the terminal."
    echo
    echo "For more information, open this script in a text editor of your choice and read the header comments for each command."
    echo
}

# Script Logic ========================================================================================================

# Get the directory path to the initialization script.

scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/scripts"

# Display a welcome message
echo "Welcome to the PIC32Linux project terminal! Type 'exit' or 'quit' to leave."
echo "If you need help, type 'h' or 'help' for more information."
echo

# Launch a shell-like terminal.
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
        i|initialize-simple)
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
                continue
            fi

            # Read flags and execute.
            case "$2" in
                -b)
                    # Run bootloader compilation script.
                    "$scripts_dir"/compile_bootloader.sh
                    ;;
                -k)
                    # Run kernel compilation script.
                    "$scripts_dir"/compile_kernel.sh
                    ;;
                *)
                    error "Invalid argument provided. Use the h or help command for more information."
                    ;;
            esac
            ;;
        m|mountfs)
            # Run mount script.

            "$scripts_dir"/mountfs.sh --mount
            ;;
        u|unmountfs)
            # Run unmount script.

            "$scripts_dir"/mountfs.sh --unmount
            ;;
        p|install-precompiled)
            # Run install precompiled script.

            "$scripts_dir"/install.sh --precompiled
            ;;
        g|install-generated)
            # Run install generated script.

            "$scripts_dir"/install.sh --generated
            ;;
        reset)
            # Check if there is exactly one argument provided and exit with error if not.

            if [ $# -ne 2 ]; then

                error "Reset needs an additional argument. Use the h or help command for more information."
                continue
            fi

            # Read flags and execute.
            case "$2" in
                -g)
                    # Delete generated (compiled) files.
                    "$scripts_dir"/reset.sh --generated
                    ;;
                -s)
                    # Delete all the source code directories.
                    "$scripts_dir"/reset.sh --sources
                    ;;
                -a)
                    # Run kernel compilation script.
                    "$scripts_dir"/reset.sh --all
                    ;;
                *)
                    error "Invalid argument provided. Use the h or help command for more information."
                    ;;
            esac
            ;;
        *)
            error "Unsupported command '$1'. Use the h or help command for more information."
            ;;
    esac
done

# Display a farewell message
echo
echo "Goodbye!"
echo

exit 0