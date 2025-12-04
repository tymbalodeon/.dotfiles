#!/usr/bin/env nu

# Set wallpaper to a specific file
export def wallpaper [wallpaper?: string] {
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
  systemctl --user stop wpaperd.service
}

def --wrapped wpaperctl [...args: string] {
  if (systemctl --user list-units | rg wpaperd | is-empty) {
    systemctl --user start wpaperd.service
    sleep 1sec
  }

  ^wpaperctl ...$args
  pkill -RTMIN+2 waybar
  try { pkill swaybg }
}

# Change to next (random) wallpaper
export def "wallpaper next" [] {
try {
  wpaperctl next
  } catch {|e| print $e}
}

# Change to previous wallpaper
export def "wallpaper previous" [] {
  wpaperctl previous
}

# Toggle pausing/resuming automatic cycling of wallpaper
export def "wallpaper toggle-pause" [] {
  wpaperctl toggle-pause
}

export def main [arg?: string] {
  match $arg {
    "next" => (wallpaper next)
    "previous" => (wallpaper previous)
    "toggle-pause" => (wallpaper toggle-pause)
    _ => (wallpaper $arg)
  }
}
