#!/usr/bin/env nu

def get-status [ ] {
  wpaperctl get-status --json
  | from json
  | first
}

export def main [] {
  let status = (get-status)

  let text = match $status.status {
    "running" => $status.duration_left
    "paused" => "off"
    _ => ""
  }

  let tooltip = (
    wpaperctl all-wallpapers --json
    | from json
    | first
    | get path
    | path basename
  )

  {
    text: $text
    tooltip: $tooltip
  }
  | to json
  | jq --compact-output --unbuffered
}
