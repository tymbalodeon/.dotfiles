#!/usr/bin/env nu

def get-first-number []: string -> string {
  $in
  | split row " "
  | first
}

def main [] {
  let values = (
    hyprctl -j --batch "getoption general:gaps_in; getoption general:gaps_out"
    | lines
    | where {is-not-empty}
    | each {|line| $line | from json}
    | transpose --header-row
    | first
    | rename in out
  )

  let gaps_in = ($values.in | get-first-number)
  let gaps_out = ($values.out | get-first-number)

  if $gaps_in == "0" and $gaps_out == "0" {
    # TODO: find a way to pull these values programmatically through nix
    hyprctl --batch "keyword general:gaps_in 8; keyword general:gaps_out 16"
  } else {
    hyprctl --batch "keyword general:gaps_in 0; keyword general:gaps_out 0"
  }
}
