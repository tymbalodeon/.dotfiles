#!/usr/bin/env nu

def get-status [ ] {
  wpaperctl get-status --json
  | from json
  | first
}

export def main [] {
  let status = (get-status)

  match $status.status {
    "running" => $status.duration_left
    "paused" => "off"
    _ => ""
  }
}
