#!/usr/bin/env nu

def main [--primary] {
  let args = [--no-newline]

  let args = if $primary {
    $args
    | append "--primary"
  } else {
    $args
  }

  let word = (wl-paste ...$args | str replace --regex "-\n" "")

  if ($word | is-empty) {
    return
  }

  let definitions = (
    curl
      --connect-timeout 5
      --max-time 10
      --silent
      $"https://api.dictionaryapi.dev/api/v2/entries/en_US/($word)"
    | from json
  )

  if ($definitions | is-empty) or title in ($definitions | columns) {
    notify-send $"\n  No definition found for \"($word)\"\n"

    return
  }

  let urls = ($definitions.sourceUrls | flatten)

  if ($urls | is-not-empty) {
    start ($urls | first)
  } else {
    print $definitions
  }
}
