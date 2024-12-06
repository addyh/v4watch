#!/bin/sh
# Version: 2024.12.6.142035

fail() {
	[ -n "$1" ] && echo "Error: $1" >&2
	echo "Usage: v4watch <config_setting> [--device=<device_path> | -d <device_path>] [--ignore=<fields_to_ignore> | -i <fields_to_ignore>] [--show-hex | -x] [--interval=<seconds> | -t <seconds>]" >&2
	echo "For more details, use -h or --help." >&2
	exit 1
}

version="v4watch version 1.3.0"
config_setting=""
ignore_fields=""
device=""
show_hex="false"
interval="0.1"

# Parse arguments
while [ "$#" -gt 0 ]; do
	case "$1" in
		-h|--help)
			echo "Usage: v4watch <config_setting> [-d <device_path>] [-i <fields_to_ignore>] [-x] [-t <seconds>]"
			echo
			echo "Description:"
			echo "  Runs a watch command on 'v4l2-ctl --all' for a specific device and config setting."
			echo
			echo "Arguments:"
			echo "  <config_setting>            The v4l2-ctl config setting to watch."
			echo "  -h, --help                  Display this help information."
			echo "  -v, --version               Display version information."
			echo "  -d, --device=<device_path>  Specify the device path to send to v4l2-ctl."
			echo "  -i, --ignore=<fields>       Comma- or space-separated list of fields to ignore in the output."
			echo "  -x, --show-hex              Show hexadecimal values and field types in the output."
			echo "  -t, --interval=<seconds>    Set the update interval for watch (default is 0.1 seconds)."
			echo
			echo "Example:"
			echo "  v4watch exposure_time_absolute --device=/dev/video1 --ignore=\"default,step,flags\" --interval=1"
			echo "  v4watch exposure_time_absolute -d /dev/video1 -i \"default step flags\" -x -t 0.5"
			echo "  v4watch auto_exposure -x"
			echo
			echo "Notes:"
			echo "  - The function will highlight the 'value' field in cyan and the config setting in green."
			echo "  - Ignored fields (such as 'default', 'step', 'flags') will be removed from the output."
			echo
			exit 0
			;;
		-v|--version)
			echo "$version"
			exit 0
			;;
		--device=*)
			device="${1#--device=}"
			;;
		--device|-d)
			shift
			[ "$#" -gt 0 ] && device="$1" || fail "Option --device or -d requires an argument."
			;;
		--ignore=*)
			ignore_fields="${1#--ignore=}"
			;;
		--ignore|-i)
			shift
			[ "$#" -gt 0 ] && ignore_fields="$1" || fail "Option --ignore or -i requires an argument."
			;;
		--show-hex|-x)
			show_hex="true"
			;;
		--interval=*)
			interval="${1#--interval=}"
			;;
		--interval|-t)
			shift
			[ "$#" -gt 0 ] && interval="$1" || fail "Option --interval or -t requires an argument."
			;;
		*)
			if [ -z "$config_setting" ]; then
				config_setting="$1"
			else
				# Append each subsequent word to ignore_fields
				ignore_fields="$ignore_fields $1"
			fi
			;;
	esac
	shift
done

# Show help if no config setting is provided
if [ -z "$config_setting" ]; then
	fail "No config setting provided."
fi

# Convert delimiters (, or space) to |
ignore_pattern=$(echo "$ignore_fields" | sed 's/[ ,]/|/g')

# Build initial command with optional device
base_command="v4l2-ctl --all"
[ -n "$device" ] && base_command="$base_command --device=$device"

# Use awk to capture specified setting with its menu options
base_command="$base_command | awk '/'"$config_setting"'/ {print; in_block=1; next} in_block && /^[[:space:]]+[0-9]+:/ {print; next} /^[^[:space:]]/ {in_block=0}'"

# Test the initial command (v4l2-ctl and awk) for errors
if ! eval "$base_command" >/dev/null 2>&1; then
	fail "Command failed. Please check the device and config setting."
fi

# Remove specified fields before applying color formatting
if [ -n "$ignore_pattern" ]; then
	command="$base_command | sed -E \"s/ ($ignore_pattern)=[^ ]*//g\""
else
	command="$base_command"
fi

# Apply color formatting
command="$command | \
	sed -E \"s/(value=[0-9]+( \([^)]*\))?)/\x1b[36m\1\x1b[0m/g\" | \
	sed -E \"s/($config_setting)/\x1b[32m\1\x1b[0m/g\""

# Conditionally include hex values if --show-hex or -x is specified
if [ "$show_hex" = "true" ]; then
	command="$command | sed -E \"s/(0x[^:]*:)/\\1\\n/g\""
else
	command="$command | sed \"s/0x[^:]*:/\\n/g\""
fi

# Run the watch command with the specified interval
watch --color -t -n "$interval" "$command"
