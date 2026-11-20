#!/usr/bin/env sh

user_autoload_dirs=$(nu --commands "\$nu.user-autoload-dirs | first")
includes="$user_autoload_dirs/openweathermap-api-key.nu"
script="$user_autoload_dirs/weather.nu"

if test -f "$includes" && test -f "$script"; then
	nu --commands "source $includes; source $script; weather waybar"
fi
