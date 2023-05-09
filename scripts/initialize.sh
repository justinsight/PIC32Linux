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

sudo apt-get install gcc-mipsel-linux-gnu srecord gzip make git wget unzip

# Download bootloader and kernel sources, then download the pic32fs image.

cd "$script_dir"/../bootloader
git clone https://github.com/sergev/u-boot-pic32.git

cd "$script_dir"/../kernel
git clone https://github.com/sergev/linux-pic32.git

cd "script_dir"/../precompiled
wget https://github.com/sergev/u-boot-pic32/files/3800047/u-boot-pic32.zip

