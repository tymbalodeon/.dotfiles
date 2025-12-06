#!/usr/bin/env nu

def main [] {
  let status = (
    sunsetr status --json
    | from json
  )

  let icon = match $status.period {
    day => ""
    night => ""
    _ => ""
  }

  let next_period = (
    $status.next_period
    | into datetime
    | date humanize
  )

  {
    text: $"($icon) ($next_period)"

    tooltip: (
      $"Temperature: ($status.current_temp)K\nGamma: ($status.current_gamma)%"
    )
  }
  | to json
  | jq --compact-output --unbuffered
}
