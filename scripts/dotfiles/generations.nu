#!/usr/bin/env nu

use ./configurations.nu is-nixos

# View generations
def main [] {
  if (is-nixos) {
    nixos-rebuild list-generations --json
    | from json
    | reject specialisations configurationRevision
    | table --index false
  } else {
    /run/current-system/sw/bin/darwin-rebuild --list-generations
  }
}
