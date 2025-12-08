#!/usr/bin/env nu

def list-units [--user] {
  let args = [
    list-units
    --output json
    --state failed
    --type service
  ]

  let args = if $user {
    $args
    | append "--user"
  } else {
    $args
  }

  systemctl ...$args
  | from json
  | get unit
}

def main [] {
  let user_units = (list-units --user)
  let system_units = (list-units)

  let failed_units_total = (
    $user_units
    | append $system_units
    | length
  )

  let tooltip = $"User:\n(
    $user_units
    | to text --no-newline
  )\n\nSystem:\n(
    $system_units
    | to text --no-newline
  )"

  {
    text: (
      if $failed_units_total == 0 {
        ""
      } else {
        $failed_units_total
      }
    )

    tooltip: $tooltip
  }
  | to json
  | jq --compact-output --unbuffered
}
