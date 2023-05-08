#!/bin/bash

#
# This script provides the necessary commands for compiling the kernel and moving the compiled
# files to the ../../generated directory.
#
#
# Modified By: Justin Newkirk
# Date       : May 8, 2023
# Project    : Linux for PIC32
#

# Get the directory path to the kernel compilation script and the generated directory path.

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
generated_dir="$script_dir/../generated"

# Remove the previously generated kernel files.

rm -r "$generated_dir"/boot
rm -r "$generated_dir"/lib

# Go to the kernel directory to perform the compilation.

cd "$script_dir"/../kernel/linux-pic32

# Perform the compilation.

make ARCH=mips pic32mzda_defconfig
make ARCH=mips CROSS_COMPILE=mipsel-linux-gnu-
gzip -9 < arch/mips/boot/vmlinux.bin > arch/mips/boot/vmlinux.bin.gz
../u-boot-pic32/tools/mkimage -A MIPS -a 0x88000000 -e 0x88000400 -d arch/mips/boot/vmlinux.bin.gz arch/mips/boot/vmlinux-pic32
mkdir -p "$generated_dir"/boot
cp -a arch/mips/boot/vmlinux-pic32 "$generated_dir"/boot/vmlinux-pic32
cp -a arch/mips/boot/dts/pic32/pic32mzda_sk.dtb "$generated_dir"/boot/pic32mzda.dtb
make ARCH=mips CROSS_COMPILE=mipsel-linux-gnu- INSTALL_MOD_PATH="$generated_dir"/.. modules_install


#make ARCH=mips CROSS_COMPILE=mipsel-linux-gnu- INSTALL_MOD_PATH=$PWD/.. modules_install
