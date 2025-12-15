#!/usr/bin/env nu

def get-status [ ] {
  try {
    wpaperctl get-status --json err> /dev/null
    | from json
    | first
  }
}

export def main [] {
  try {
    if (ls ($env.HOME | path join wallpaper) | length) < 2 {
      return
    }
  } catch {
    return
  }

  let status = (get-status)

  let text = if ($status | is-empty) {
   "off" 
  } else {
    match $status.status {
      running => {
        let duration = $status.duration_left

        if ($duration | str ends-with s) {
          "<1m"
        } else {
          $duration
        }
      }

      _ => "off"
    }
  }

  let tooltip = try {
    wpaperctl all-wallpapers --json err> /dev/null
    | from json
    | first
    | get path
    | path basename
    | path parse
    | get stem
  } catch {
    ""
  }

  {
    text: $text
    tooltip: $tooltip
  }
  | to json
  | jq --compact-output --unbuffered
}
