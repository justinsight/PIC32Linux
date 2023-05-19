#!/bin/bash


# A simple function that is used to verify a user's acknowledgement.
# Primarily used to make sure that a user has completed an important
# step in the process.
#
# Will return a 0 if verified; 1 otherwise.
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
	echo
	echo "WARNING - Do NOT insert any other device during this stage."	
	echo
	echo "Waiting for the device... (Will attempt for 30sec)"
    
    	# Check for the new device 30 times (ie, for 30 seconds). 
    	for (( i=1; i<=30; i++ )); do
        	sleep 1
	
		# Compare the state of /dev before and after.
        	after=$(ls /dev)

        	# Find differences
        	new_device=$(comm -13 <(sort <(echo "$before")) <(sort <(echo "$after")))

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
	
    	# Return the name of the new device
    	echo $new_device
}

# Get the name of the USB device
default_device=$(ls /dev | grep ttyACM)

# If no device is found, attempt to detect it
if [ -z "$default_device" ]; then
	
	echo "Default serial device was not found."
	echo "Searching... Please follow the instructions provided."

	# Will automatically exit with an error if no device was found.
	detect_new_device
fi

# Prepend /dev/ to the device name.
device="/dev/$new_device"


# FOR TESTING
echo "TESTING - The device we're about to connect to is: ${device}"
exit 0

# Connect to the device using the screen command.
echo "Connecting to $device at 115200 baud..."

screen $device 115200,cs8,-parenb,-cstopb,-hupcl

