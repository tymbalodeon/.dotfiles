#!/usr/bin/env nu

const DISPLAY_NUM = "1"
const CURRENT_BRIGHTNESS_FILE = "/tmp/current-brightness.tmp"
const PREVIOUS_BRIGHTNESS_FILE = "/tmp/previous-brightness.tmp"
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

def open-current-brightness-file [] {
  let current_brightness = if ($CURRENT_BRIGHTNESS_FILE | path exists) {
    open $CURRENT_BRIGHTNESS_FILE
  } else {
    let current_brightness = (
      ddcutil --display $DISPLAY_NUM --terse getvcp 10
      | split words
      | get 3
    )

    $current_brightness
    | save --force $CURRENT_BRIGHTNESS_FILE

    $current_brightness
  }

  $current_brightness
  | into int
}

def open-previous-brightness-file [] {
  if ($PREVIOUS_BRIGHTNESS_FILE | path exists) {
    open $PREVIOUS_BRIGHTNESS_FILE
    | into int
  } else {
    50
  }
}

def get-brightness [] {
  open-current-brightness-file
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
  | save --force $CURRENT_BRIGHTNESS_FILE

  pkill -RTMIN+1 waybar
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

def "main dim" [] {
  open-current-brightness-file
  | save --force $PREVIOUS_BRIGHTNESS_FILE

  main set min
}

def "main restore" [] {
  set-brightness (open-previous-brightness-file)
  rm --force $PREVIOUS_BRIGHTNESS_FILE
}

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
