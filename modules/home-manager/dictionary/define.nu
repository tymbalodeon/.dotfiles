#!/usr/bin/env nu

def main [--primary] {
  # TODO: make a shared function with search.nu?
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

  let definitions = try {
    (
      http get
        $"https://api.dictionaryapi.dev/api/v2/entries/en_US/($word)"
    )
  } catch {
    notify-send $"\n  No definition found for \"($word)\"\n"

    return
  }

  let urls = ($definitions.sourceUrls | flatten)

  if ($urls | is-not-empty) {
    # TODO: focus the window after opening (use shared functions in
    # modules/home-manager/window-manager)
    start ($urls | first)
  } else {
    print $definitions
  }
}
