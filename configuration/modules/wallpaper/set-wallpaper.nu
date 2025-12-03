#!/usr/bin/env nu

use notify-wallpaper-status.nu 
use ../waybar/update-waybar.nu

def main [] {}

def --wrapped wpaperctl [...args: string] {
  ^wpaperctl ...$args
  update-waybar 2
  notify-wallpaper-status
}

def "main next" [] {
  wpaperctl next
}

def "main previous" [] {
  wpaperctl next
}

def "main toggle-pause" [] {
  wpaperctl next
}
