#!/usr/bin/env nu

const DISPLAY_NUM = "1"
const STATE_FILE = "/tmp/waybar-brightness.tmp"
const STEP = 5

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

def get-brightness [] {
  let current_brightness = if not ($STATE_FILE | path exists) {
    let current_brightness = (
      ddcutil --display $DISPLAY_NUM --terse getvcp 10
      | split words
      | get 3
    )

    $current_brightness
    | save --force $STATE_FILE

    $current_brightness
  } else {
    open $STATE_FILE
  }

  $current_brightness
  | into int
}

def set-brightness [
  new_value: int
  old_value?: int
] {
  if $old_value == $new_value {
    return
  }

  ddcutil --display $DISPLAY_NUM setvcp 10 ($new_value | into string)

  $new_value
  | save --force $STATE_FILE

  pkill -RTMIN+8 waybar
}

def get-new-brightness [value: int] {
  let value = ($value | into int)

  if $value < 0 {
    "0"
  } else if $value > 100 {
    "100"
  } else {
    $value
  }
}

def main [] {}

def "main set max" [] {
  set-brightness 100
}

def "main set min" [] {
  set-brightness 0
}

def "main decrease" [] {
  let current_brightness = (get-brightness)
  let new_brightness = (get-new-brightness ($current_brightness - $STEP))

  set-brightness $new_brightness $current_brightness 
}

def "main get" [] {
  get-brightness
}

def "main increase" [] {
  let current_brightness = (get-brightness)
  let new_brightness = (get-new-brightness ($current_brightness + $STEP))

  set-brightness $new_brightness $current_brightness
}
