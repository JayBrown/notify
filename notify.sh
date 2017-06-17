#!/bin/bash

ACCOUNT=$(/usr/bin/id -un)
PROCESS="Process Name" # exchange for actual process name depending on your script
ICON_LOC="/.VolumeIcon.icns" # exchange for actual path to the icon image file

# notify function
notify () {
 	if [[ "$TN_STATUS" == "osa" ]] ; then # notify with AppleScript
		/usr/bin/osascript &>/dev/null << EOT
tell application "System Events"
	display notification "$2" with title "$PROCESS [" & "$ACCOUNT" & "]" subtitle "$1"
end tell
EOT
	elif [[ "$TN_STATUS" == "tn-app" ]] ; then # old method with terminal-notifier.app
		"$TN_LOC/Contents/MacOS/terminal-notifier" \
			-title "$PROCESS [$ACCOUNT]" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$ICON_LOC" \
			>/dev/null
	elif [[ "$TN_STATUS" == "tn-cli" ]] ; then # new method with terminal-notifier
		"$TN" \
			-title "$PROCESS [$ACCOUNT]" \
			-subtitle "$1" \
			-message "$2" \
			-sender SystemEvents \
			-appIcon "$ICON_LOC" \
			>/dev/null
	fi
}

# look for terminal-notifier
TN=$(which terminal-notifier)
if [[ "$TN" == "" ]] || [[ "$TN" == *"not found" ]] ; then
	TN_LOC=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | /usr/bin/awk 'NR==1')
	if [[ "$TN_LOC" == "" ]] ; then
		TN_STATUS="osa"
	else
		TN_STATUS="tn-app"
	fi
else
	TN_VERS=$("$TN" -help | /usr/bin/head -1 | /usr/bin/awk -F'[()]' '{print $2}' | /usr/bin/awk -F. '{print $1"."$2}')
	if [[ "$TN_VERS" == "" ]] || (( $(echo "$TN_VERS < 1.8" | /usr/bin/bc -l) )) ; then
		TN_LOC=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | /usr/bin/awk 'NR==1')
		if [[ "$TN_LOC" == "" ]] ; then
			TN_STATUS="osa"
		else
			TN_STATUS="tn-app"
		fi
	else
		TN_STATUS="tn-cli"
	fi
fi

# notify: exchange subtitle & message text for the actual strings
notify "subtitle" "message text"
