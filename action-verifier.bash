#!/bin/bash

# Check if a given action has been successfully finished, or terminated with errors
# A suitable message will be displayed.
#
# Parameters:
#	status - should be sent as "$?", this is the status code of the desired action.
#	action - display name of the performed action.
#	title - display title of the performed action.
#	multi_flag - "1" - if the action referes to multiple items. "0" - otherwise.
verify_action(){
	local status="$1"
	local action="$2"
	local title="$3"
	local multi_flag="$4"
	
	# Handle case of no multi_flag supplied.
	if [ -z "$multi_flag" ]
	then
		multi_flag="0" # Default multi_flag is "0", which means - a single item is provided.
	fi
	
	# Determine how to display the performed action in past progressive format.
	local action_performed="${action}"
	if [ "$action_performed" != "set" ];
	then
		local last_char="${action: -1}"
		
		if [ "$last_char" = "e" ];
		then
			action_performed+="d"
		else
			action_performed+="ed"
		fi
	fi
	
	# Determine the suitable verb to describe the performed action.
	if [ $multi_flag -eq "1" ]
	then
		verb="have"
	else
		verb="has"
	fi
	
	# Display the desired output
	if [ $status -eq 0 ]
	then
		echo "$title, $verb been successfully $action_performed"
	else
		echo "Failed to $action $title" >&2
		exit 1
	fi
}