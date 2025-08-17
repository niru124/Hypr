#!/usr/bin/env sh

# Save current shader and turn it off
restore_shader() {
	if [ -n "$shader" ]; then
		hyprshade on "$shader"
	fi
}

save_shader() {
	shader=$(hyprshade current)
	hyprshade off
	trap restore_shader EXIT
}

save_shader

# Fallbacks
if [ -z "$XDG_PICTURES_DIR" ]; then
	XDG_PICTURES_DIR="$HOME/Pictures"
fi

# Directories and filenames
confDir="$HOME/.config"
swpy_dir="${confDir}/swappy"
save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
temp_screenshot="/tmp/screenshot.png"

mkdir -p "$save_dir"
mkdir -p "$swpy_dir"
echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" >"$swpy_dir/config"

print_error() {
	cat <<"EOF"
    ./screenshoti.sh <action>
    ...valid actions are...
        p  : print all screens
        s  : snip current screen
        sf : snip current screen (frozen)
        m  : print focused monitor
EOF
}

# Clear previous temp file if exists
rm -f "$temp_screenshot"

case $1 in
p)
	grimblast copysave screen "$temp_screenshot"
	swappy -f "$temp_screenshot"
	;;
s)
	grimblast copysave area "$temp_screenshot"
	swappy -f "$temp_screenshot"
	;;
sf)
	grimblast --freeze copysave area "$temp_screenshot"
	swappy -f "$temp_screenshot"
	;;
m)
	grimblast copysave output "$temp_screenshot"
	swappy -f "$temp_screenshot"
	;;
*)
	print_error
	exit 1
	;;
esac

# Wait until screenshot is actually saved
tries=0
while [ ! -s "$temp_screenshot" ] && [ $tries -lt 50 ]; do
	sleep 0.1
	tries=$((tries + 1))
done

# Notify if it worked
if [ -s "$temp_screenshot" ]; then
	cp "$temp_screenshot" "$save_dir/$save_file"
		notify -a "t1" -i "${save_dir}/${save_file}" "saved in ${save_dir}" -screen-capture
else
	notify-send -a "Screenshot" "Screenshot failed."
	exit 1
fi

