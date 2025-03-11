#!/usr/bin/env nu

use ./configurations.nu is-nixos

# Rollback to a previous generation
def main [
  generation_id: int
] {
    # TODO add NixOS version? Is this possible?
  if (is-nixos) {
    print "Feature not available on NixOS."

    exit 1
  }

  let paths = (
    # TODO update to darwin-rebuild
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
