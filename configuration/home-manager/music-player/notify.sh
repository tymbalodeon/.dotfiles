#!/usr/bin/env sh

tmp_dir="/tmp/rmpc"

mkdir --parents "$tmp_dir"

album_art_path="$tmp_dir/notification_cover"

if ! rmpc albumart --output "$album_art_path"; then
	album_art_path="$tmp_dir/default_album_art.jpg"
fi

notify-send --icon "${album_art_path}" "Now Playing" "$ALBUMARTIST - $TITLE"
