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
#	* -i --initialize
#
#		* This will install all relevant software for compilation, apply permissions for all scripts, download the premade
#		  file system image, and download the source code for the bootloader and kernel.
#
#		* This should be run at the beginning before anything else.
#
#
#
#
#
#
#
#
# Author : Justin Newkirk
# Date   : May 8, 2023
# Project: Linux for PIC32.
#


