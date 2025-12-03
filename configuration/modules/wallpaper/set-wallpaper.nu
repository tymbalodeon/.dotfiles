#!/usr/bin/env nu

export def main [] {}

def --wrapped wpaperctl [...args: string] {
  ^wpaperctl ...$args
  pkill -RTMIN+2 waybar
}

export def "main next" [] {
  wpaperctl next
}

export def "main previous" [] {
  wpaperctl previous
}

export def "main toggle-pause" [] {
  wpaperctl toggle-pause
}
