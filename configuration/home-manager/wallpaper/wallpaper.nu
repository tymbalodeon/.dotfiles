#!/usr/bin/env nu

# Set wallpaper to a specific file
export def main [wallpaper?: string] {
  let wallpaper = if ($wallpaper | is-empty) {
    ls --short-names ~/wallpaper
    | get name
    | to text
    | fzf
  } else {
    $wallpaper
  }

  let wallpaper = if ($wallpaper | path dirname) not-in [
    $"($env.HOME)/wallpaper"
    "~/wallpaper"
  ] {
    [
      $env.HOME
      wallpaper
      $wallpaper
    ]
    | path join
  } else {
    $wallpaper
  }

  if not ($wallpaper | path exists) {
    return
  }

  bash -c $"swaybg --image '($wallpaper)' &" out+err> /dev/null
  pkill -RTMIN+2 waybar
  systemctl --user stop wpaperd
}

# Clear the wallpaper folder
export def clear [] {
  rm ~/wallpaper/*
}

# Load wallpapers
export def load [path: string] {
  let path = ($path | path expand)

  let files = if ($path | path type) == file {
    $path
  } else {
    ls $path
    | get name
  }

  for file in $files {
    ln --symbolic $file ~/wallpaper
  }
}

def --wrapped wpaperctl-wrapper [...args: string] {
  if (systemctl --user list-units | rg wpaperd | is-empty) {
    systemctl --user start wpaperd
    sleep 500ms

    if toggle-pause in $args {
      wpaperctl toggle-pause
    }
  }

  wpaperctl ...$args
  pkill -RTMIN+2 waybar
  try { pkill swaybg }
}

# Change to next (random) wallpaper
export def next [] {
  wpaperctl-wrapper next
}

# Add padding to image to account for status bar
export def pad [image: string] {
  const WAYBAR_HEIGHT = 55

  let resolution = (xrandr | rg '\*' | split words | first | split row x)
  let padded_width = ($resolution | first)
  let padded_height = (($resolution | last | into int) + $WAYBAR_HEIGHT)
  let resolution = ($resolution | str join x)
  let padded_resolution = ([$padded_width $padded_height] | str join x)

  (
    magick
      $image
      -background black
      -gravity north
      -extent $padded_resolution
      -resize $resolution
      $image
  )
}

# Add padding to all images in the wallpaper folder
Export def "pad all" [] {
  for image in (ls ~/wallpaper | get name) {
    pad $image
  }
}

alias start = next

# Change to previous wallpaper
export def previous [] {
  wpaperctl-wrapper previous
}

# Toggle pausing/resuming automatic cycling of wallpaper
export def toggle-pause [] {
  wpaperctl-wrapper toggle-pause
}
