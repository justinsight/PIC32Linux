#!/bin/bash

# 
# This file contains the script that will automatically find the plugged in Curiosity Board in devices
# and then connect to it using serial.
# It is very important that the instructions provided by this script be followed very carefully as there
# are some commands within that, if run improperly and at the wrong time, could cause issues.
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
		
		echo "Verify [y, n]: "
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

# This will allow us to detect the newly plugged in Curiosity Board if the default name was not in fact
# found already.
function detect_new_device() {

    	verify "Please ensure that the microntroller is unplugged."

    	# Capture the current state of /dev.
    	before=$(ls /dev)

    	# Tell the user to plug in the microcontroller again.

	echo "Please plug in the Curiosity board into the computer."
	echo "WARNING - Do NOT insert any other device during this stage."	
	echo "Waiting for the device... (Will attempt for 30sec)"
    
    	# Check for the new device 30 times (ie, for 30 seconds). 
    	for (( i=1; i<=30; i++ )); do
		# Compare the state of /dev before and after.
        	after=$(ls /dev)

        	# Find differences
        	new_device=$(comm -13 <(sort <(echo "$before")) <(sort <(echo "$after")) | tail -n 1)

        	# If a new device is found, break the loop
        	if [ ! -z "$new_device" ]; then
            		break
        	fi
    	done

    	# If no device is found after the loop, exit with an error
    	if [ -z "$new_device" ]; then
        	echo "No new USB device detected. Please try again."
        	exit 1
    	fi
}

# Script Logic ============================================================

echo "Please follow the instructions provided."

new_device=""

# Will automatically exit with an error if no device was found.
detect_new_device

# Prepend /dev/ to the device name.
device="/dev/$new_device"

# Connect to the device using the screen command.
echo "Connecting to $device at 115200 baud..."

sleep 1

sudo screen $device 115200,cs8,-parenb,-cstopb,-hupcl

