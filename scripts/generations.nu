#!/usr/bin/env nu

use ./hosts.nu is_nixos

# View generations
def main [] {
  if (is_nixos) {
    nixos-rebuild list-generations --json
    | from json
    | reject specialisations configurationRevision
    | table --index false
  } else {
    home-manager generations
  }
}
