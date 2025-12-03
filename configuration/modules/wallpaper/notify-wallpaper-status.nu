#!/usr/bin/env nu

use get-wallpaper-status.nu 

export def main [] {
  let status = (get-wallpaper-status)

  notify-send --urgency low $"\n\tAutomatic wallpaper cycling: ($status)\n"
}
