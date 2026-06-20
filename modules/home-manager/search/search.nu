#!/usr/bin/env nu

def main [--primary] {
  # TODO: make a shared function with define.nu?
  let args = [--no-newline]

  let args = if $primary {
    $args
    | append "--primary"
  } else {
    $args
  }

  let selection = (wl-paste ...$args | str replace --regex "-\n" "")

  if ($selection | is-empty) {
    return
  }

  xdg-open $"https://www.mojeek.com/search?q=($selection)"
}
