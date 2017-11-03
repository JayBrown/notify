#!/bin/bash

# updated for terminal-notifier v2.0.0: https://github.com/julienXX/terminal-notifier

account=$(/usr/bin/id -un)
process="Process Name" # exchange for actual process name depending on your script
icon_loc="/.VolumeIcon.icns" # exchange for actual path to the icon image file

# notify function
notify () {
 	if [[ "$tn_status" == "osa" ]] ; then
		osascript &>/dev/null << EOT
tell application "System Events"
	display notification "$2" with title "$process [" & "$account" & "]" subtitle "$1"
end tell
EOT
	elif [[ "$tn_status" == "tn-app-new" ]] || [[ "$tn_status" == "tn-app-old" ]] ; then
		"$tn_loc/Contents/MacOS/terminal-notifier" \
			-title "$process [$account]" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$icon_loc" \
			>/dev/null
	elif [[ "$tn_status" == "tn-cli" ]] ; then
		"$tn" \
			-title "$process [$account]" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$icon_loc" \
			>/dev/null
	fi
}

# look for terminal-notifier
tn=$(which terminal-notifier 2>/dev/null)
if [[ "$tn" == "" ]] || [[ "$tn" == *"not found" ]] ; then
	tn_loc=$(mdfind "kMDItemCFBundleIdentifier == 'fr.julienxx.oss.terminal-notifier'" 2>/dev/null | awk 'NR==1')
	if [[ "$tn_loc" == "" ]] ; then
		tn_loc=$(mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | awk 'NR==1')
		if [[ "$tn_loc" == "" ]] ; then
			tn_status="osa"
		else
			tn_status="tn-app-old"
		fi
	else
		tn_status="tn-app-new"
	fi
else
	tn_vers=$("$tn" -help | head -1 | awk -F'[()]' '{print $2}' | awk -F. '{print $1"."$2}')
	if (( $(echo "$tn_vers >= 1.8" | bc -l) )) && (( $(echo "$tn_vers < 2.0" | bc -l) )) ; then
		tn_status="tn-cli"
	else
		tn_loc=$(mdfind "kMDItemCFBundleIdentifier == 'fr.julienxx.oss.terminal-notifier'" 2>/dev/null | awk 'NR==1')
		if [[ "$tn_loc" == "" ]] ; then
			tn_loc=$(mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | awk 'NR==1')
			if [[ "$tn_loc" == "" ]] ; then
				tn_status="osa"
			else
				tn_status="tn-app-old"
			fi
		else
			tn_status="tn-app-new"
		fi
	fi
fi

# notify: exchange subtitle & message text for the actual strings (using test notification)
notify "Test notification" "Status: $tn_status"

# print variables (only for testing)
echo "\$PATH: $tn"
echo "Version: $tn_vers"
echo ".app executable location: $tn_loc"
echo "Status: $tn_status"

# test notification directly from $PATH
terminal-notifier -title "$process [$account]" -subtitle "Test notification" -message "$tn" -appIcon "$icon_loc"
