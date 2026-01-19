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
  pkill -RTMIN+2 waybar
  systemctl --user stop wpaperd
}

export def "wallpaper clear" [] {
  rm ~/wallpaper/*
}

export def "wallpaper load" [path: string] {
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
export def "wallpaper next" [] {
  wpaperctl-wrapper next
}

# Change to previous wallpaper
export def "wallpaper previous" [] {
  wpaperctl-wrapper previous
}

# Toggle pausing/resuming automatic cycling of wallpaper
export def "wallpaper toggle-pause" [] {
  wpaperctl-wrapper toggle-pause
}

export def main [arg?: string] {
  match $arg {
    "next" => (wallpaper next)
    "previous" => (wallpaper previous)
    "toggle-pause" => (wallpaper toggle-pause)
    _ => (wallpaper $arg)
  }
}
