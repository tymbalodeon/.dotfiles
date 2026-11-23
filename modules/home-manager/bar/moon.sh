#!/usr/bin/env sh

user_autoload_dirs=$(nu --commands "\$nu.user-autoload-dirs | first")
script="$user_autoload_dirs/astro.nu"

if test -f "$script"; then
	nu --commands "source $script; astro moon waybar"
fi
