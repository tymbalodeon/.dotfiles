#!/usr/bin/env nu

def main [] {}

def "main get" [] {
  let status = try {
    sunsetr status --json
    | from json
  } 

  let day_icon = ""

  let icon = if ($status | is-empty) {
    $day_icon
  } else {
    match $status.period {
      day => $day_icon
      night => ""
      _ => ""
    }
  }

  let next_period = if ($status | is-empty) {
    "off"
  } else {
    $status.next_period
    | into datetime
    | date humanize
  }

  let current_temperature = if ($status | is-not-empty) {
    $status.current_temp
  }

  let current_gamma = if ($status | is-not-empty) {
    $status.current_gamma
  }

  let tooltip = if ($current_temperature | is-not-empty) and (
    $current_gamma | is-not-empty
  ) {
    $"Temperature: ($current_temperature)K\nGamma: ($current_gamma)%"
  }

  {
    text: $"($icon) ($next_period)"
    tooltip: $tooltip
  }
  | to json
  | jq --compact-output --unbuffered
}

def "main toggle" [] {
  if (pgrep sunsetr | complete | get exit_code) == 0 {
    sunsetr stop
  } else {
    sunsetr --background
    sleep 500ms
  }

  pkill -RTMIN+3 waybar
}
