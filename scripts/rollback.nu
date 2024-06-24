#!/usr/bin/env nu

use ./hosts.nu is_nixos

# Rollback to a previous generation
export def main [
  generation_id: int
] {
  if (is_nixos) {
    print "Feature not available on NixOS."

    exit 1
  }

  let paths = (
    home-manager generations
    | lines
    | each {
        |line|

        let row = ($line | split row " ")
        let id = ($row | get 4)
        let path = ($row | last)

        {id: $id, path: $path}
    } | where id == ($generation_id | into string)
    | get path
  )

  if not ($paths | is-empty) {
    ^$"($paths | first)/activate"
  } else {
    print $"Generation ($generation_id) not found."

    exit 1
  }
}
