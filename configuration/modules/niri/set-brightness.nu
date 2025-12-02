#!/usr/bin/env nu

def --wrapped ddcutil [...args: string] {
  (
    ^ddcutil
      --disable-dynamic-sleep
      --display 1
      --noverify
      --skip-ddc-checks
      --sleep-multiplier .3
      ...$args
  )
}

def get-current-brightness [] {
  ddcutil getvcp 10
  | split row "current value ="
  | last
  | split row ","
  | first
  | str trim
  | into int
}

def set-brightness [value: int] {
  ddcutil setvcp 10 ($value | into string)
}

def notify [
  value: int
  --decrease
  --increase
] {
  let icon = if $increase {
    ""
  } else if $decrease {
    ""
  } else {
    ""
  }

  notify-send $"\n\t($icon)  ($value)%\n"
}

const increment = 10

def "main decrease" [] {
  let new_value = ((get-current-brightness) - $increment)

  set-brightness $new_value
  notify --decrease $new_value
}

def "main increase" [] {
  let new_value = ((get-current-brightness) + $increment)

  set-brightness $new_value
  notify --increase $new_value
}

def main [] {}
