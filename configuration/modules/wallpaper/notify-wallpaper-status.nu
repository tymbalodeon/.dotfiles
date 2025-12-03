#!/usr/bin/env nu

def main [] {
  let status = (
    wpaperctl get-status --json
    | from json
    | get status
    | first
  )

  notify-send --urgency low $"\n\tAutomatic wallpaper cycling: ($status)\n"
}
