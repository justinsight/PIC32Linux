#!/bin/bash

# 
# This program will find and flash a MicroSD card that was just plugged in 
# with the pic32fs.img, which contains the prebuilt linux file system and
# kernel/modules.
#
# This program will require some user participation as it will detect the
# MicroSD card after it has determined all the devices that are currently
# attached to the system in /dev/...
#
# The program will guide the user to make sure that the MicroSD card in question
# is not already plugged in, scan the current devices, have the user plug in the 
# device and confirm that, rescan the devices, and then flash the .img once
# everything is confirmed.
#
# Author : Justin Newkirk
# Date   : May 18, 2023
# Project: Linux on PIC32
#

# Function Definitions ==================================================

# A simple function that is used to verify a user's acknowledgement.
# Primarily used to make sure that a user has completed an important
# step in the process.
#
# Will return a 0 if verified; 1 otherwise.
#
function verify(){

	# Print verify message
	echo "$1"

	attempt=0
	user_input=""
	while [[ "$attempt" -lt 3 ]]; do


        	attempt=$(( attempt + 1 ))
		
		echo "Verify [y for yes, n for no]: "
		read user_input

		# See if the user said no. Attempt three times to receive a 

    		if [[ "$user_input" == "n" ]] || [[ "$user_input" == "no" ]]; then
        		echo "WARNING - Please follow the instruction and type 'y' or 'yes' after you have completed it."
			continue
    		fi

		# See if the user said yes.
    		if [[ "$user_input" == "y" ]] || [[ "$user_input" == "yes" ]]; then
        		echo "Successfully verified."
			return 0
    		fi
	done

	echo "ERROR - Failed to verify. Flashfs failed, please run again."
	echo 

	exit 1
}

# Function to detect new device
detect_new_device() {
	
	# Initial scan of the block devices
	initial_devices=$(lsblk -nrpo "name,type,size" | awk '$2=="disk"{print $1}')
	
	echo "Please insert the MicroSD Card into the computer."
	echo
	echo "WARNING - Do NOT insert any other device during this stage."	
	echo
	echo "Waiting for the device... (Will attempt for 30sec)"
	
	attempt=0
  	
	# Attempt to observe the new device for 30 seconds.
	
	while [[ "$attempt" -lt 30 ]]; do

    		sleep 1
		
        	attempt=$(( attempt + 1 ))

    		current_devices=$(lsblk -nrpo "name,type,size" | awk '$2=="disk"{print $1}')
    		diff <(echo "$initial_devices") <(echo "$current_devices") | grep -q ">" && break
  	done

  	new_device=$(diff <(echo "$initial_devices") <(echo "$current_devices") | grep ">" | awk '{print $2}')
  	
	echo "MicroSD Card detected: $new_device"
}


# Script Logic ==========================================================

# Get the script's current directory
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# The path to the image file
img_file="${scripts_dir}/../precompiled/pic32fs.img"

# Check if the image file exists
if [ ! -f "$img_file" ]; then
  echo "ERROR - Image file does not exist. Please run the initialization script."
  exit 1
fi

# Give the user a welcome message.

echo
echo "Welcome to the .img flasher utility!"
echo
echo "WARNING - This is a very powerful script, so please follow instructions carefully, otherwise severe system damage could potentially ensue."
echo

# Verify that the user does NOT have the MicroSD card plugged into the system.
verify "Please verify that the MicroSD card is NOT plugged into the computer."

# Call the function to wait for new device
detect_new_device

# Show the device details

echo "Device Details: "
sudo lsblk | grep $( basename "$new_device" )
echo


# Double check with the user that they are sure that they want to write to thefound device.

verify "Do these device details look correct? If yes, .img will be flashed"

# Burn the image to the device
echo "Burning image to the device: $new_device"
dd if=$img_file of=$new_device bs=4M status=progress

echo "Finished burning image to the device"


