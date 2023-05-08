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

# Give all the scripts the proper permissions.

chmod +rwx "$script_dir"/*.sh

# Install relevant pieces of software.

sudo apt-get install gcc-mipsel-linux-gnu srecord gzip make
#sudo apt-get install gzip
#sudo apt-get install make

