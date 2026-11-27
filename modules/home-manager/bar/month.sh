#!/usr/bin/env sh

user_autoload_dirs=$(nu --commands "\$nu.user-autoload-dirs | first")
script="$user_autoload_dirs/astro.nu"

if test -f "$script"; then
	if [ "$1" = "info" ]; then
		nu --commands "source $script; astro lunar-month info"
	else
		nu --commands "source $script; astro lunar-month waybar"
	fi
fi
