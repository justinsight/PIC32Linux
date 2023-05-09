#!/bin/bash

#
# This script will provide the user the ability to list all relevant files that need to be modified for
# customizing the bootloader or kernel source code to operate with different hardware configurations.
#
# This will currently only list the files that need to be modified for remapping the UART pins.
#
# Usage:
#
#   ./list.sh <flag>
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

# Function definitions =================================================================================================

# This will list all the files that are relevant for remapping the UART pins for serial communication.
list_serial(){

    echo "Files concerning serial communication: ==============================================="
    echo
    echo "Bootloader UBoot ----------------------"
    echo
    echo "Changed:"
    echo "  ./bootloader/u-boot-pic32/board/microchip/pic32mzda/pic32mzda.c"
    echo "  ./bootloader/u-boot-pic32/arch/mips/include/asm/arch-pic32/pic32.h"
    echo "  ./bootloader/u-boot-pic32/include/configs/pic32mzdask.h"
    echo
    echo "Useful:"
    echo "  ./bootloader/u-boot-pic32/drivers/serial/serial_pic32.c"
    echo
    echo "Linux Kernel --------------------------"
    echo
    echo "Changed:"
    echo "  ./kernel/linux-pic32/arch/mips/pic32/pic32mzda/early_console.c"
    echo "  ./kernel/linux-pic32/arch/mips/boot/dts/pic32/pic32mzda_sk.dts"
    echo 
    echo "Useful:"
    echo "  ./kernel/linux-pic32/drivers/tty/serial/pic32_uart.h"
    echo "  ./kernel/linux-pic32/drivers/tty/serial/pic32_uart.c"
    echo "  ./kernel/linux-pic32/arch/mips/pic32/pic32mzda/early_pin.h"
    echo "  ./kernel/linux-pic32/arch/mips/include/asm/mach-pic32/pic32.h"
    echo "  ./kernel/linux-pic32/arch/mips/boot/dts/pic32/pic32mzda.dtsi"
    echo "  ./kernel/linux-pic32/arch/mips/pic32/pic32mzda/init.c"
    echo

board/microchip/pic32mzda/pic32mzda.c
arch/mips/include/asm/arch-pic32/pic32.h
include/configs/pic32mzdask.h
drivers/serial/serial_pic32.c
}

# An error function that takes in an error message, outputs to std_err and exits with error code 1.
error() {
    echo "ERROR - $1" >&2
    exit 1
}


# Script Logic ========================================================================================================

# Get the directory path to the initialization script.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Check if there is exactly one argument provided and exit with error if not.

if [ $# -ne 1 ]; then

    error "Need exactly one argument. Use the -h or --help flag for more information."
fi

# Read flags and execute.

case "$1" in

    -s|--serial)
        list_serial
        exit 0
        ;;
    *)
        error "Invalid flag provided. Use the -h or --help flag for more information."
        ;;

esac