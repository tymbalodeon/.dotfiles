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

def get-unit-names [units: list<string> type: string] {
  if ($units | is-empty) {
    ""
  } else {
    $"($type):\n(
      $units
      | each {$'- ($in)'}
      | to text --no-newline
    )"
  }
}

def main [] {
  let system_units = (list-units)
  let user_units = (list-units --user)

  let all_units = (
    $user_units
    | append $system_units
  )

  let tooltip = (
    [
      (get-unit-names $system_units System)
      (get-unit-names $user_units User)
    ]
    | where {is-not-empty}
    | str join "\n"
  )

  {
    text: (
      if ($all_units | is-empty) {
        ""
      } else {
        $all_units
        | length
      }
    )

    tooltip: $tooltip
  }
  | to json
  | jq --compact-output --unbuffered
}
