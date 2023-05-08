#!/bin/bash

#
# This script will run the necessary commands for compiling the UBoot bootloader.
#
# WARNING - This file must be in the /bootloader directory to have any affect.
#           If the ./cmd --initialize command was executed properly, then this will not be
#           an issue.
#
#
# Modified By: Justin Newkirk
# Date       : May 8, 2023
#
#

make pic32mzdask_defconfig
make CROSS_COMPILE=mipsel-linux-gnu-
USE_PRIVATE_LIBGCC=arch/mips/lib/libgcc.a CONFIG_USE_PRIVATE_LIBGCC=y
(
    srec_cat -output --intel -gen 0x1FC00000 0x1FC00004 -l-e-const 0x0B401000 4
    srec_cat -output --intel -gen 0x1FC00004 0x1FC00008 -l-e-const 0x00000000 4
    srec_cat -output --intel -gen 0x1FC0FFBC 0x1FC0FFC0 -l-e-const 0xF4FFFFFF 4
    srec_cat -output --intel -gen 0x1FC0FFC0 0x1FC0FFC4 -l-e-const 0xFEFFFFFF 4
    srec_cat -output --intel -gen 0x1FC0FFC4 0x1FC0FFC8 -l-e-const 0xF7F9B11A 4
    srec_cat -output --intel -gen 0x1FC0FFC8 0x1FC0FFCC -l-e-const 0x5F74FCF9 4
    srec_cat -output --intel -gen 0x1FC0FFCC 0x1FC0FFD0 -l-e-const 0xF7FFFFD3 4
) | grep -v ':00000001FF' > u-boot.hex
srec_cat -output - -intel u-boot.bin -binary -offset 0x1D004000 >> u-boot.hex
