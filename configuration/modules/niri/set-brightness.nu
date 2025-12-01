#!/usr/bin/env nu

def get-current-brightness [] {
  ddcutil --display 1 getvcp 10
  | split row "current value ="
  | last
  | split row ","
  | first
  | str trim
  | into int
}

def set-brightness [value: int] {
  ddcutil --display 1 setvcp 10 $value
}

def notify [value: int] {
  notify-send $"Brightness: ($value)"
}

const increment = 10

def "main decrease" [] {
  let new_value = ((get-current-brightness) - $increment)

  set-brightness $new_value
  notify $new_value
}

def "main increase" [] {
  let new_value = ((get-current-brightness) + $increment)

  set-brightness $new_value
  notify $new_value
}

def main [] {}
