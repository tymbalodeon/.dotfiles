#!/usr/bin/env nu

def main [] {
  let word = (wl-paste --no-newline --primary)

  if ($word | is-empty) {
    return
  }

  let definitions = (
    curl
      --connect-timeout 5
      --max-time 10
      --silent
      $"ttps://api.dictionaryapi.dev/api/v2/entries/en_US/($word)"
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
