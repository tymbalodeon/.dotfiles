#!/usr/bin/env nu

def main [] {
  let current_setting = (
    hyprctl -j getoption input:follow_mouse
    | from json
    | get int
  )

  let new_setting = if $current_setting == 0 {
    1
  } else {
    0
  }

  hyprctl keyword input:follow_mouse $new_setting
}
