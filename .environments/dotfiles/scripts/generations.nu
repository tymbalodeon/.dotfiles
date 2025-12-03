#!/usr/bin/env nu

use configurations.nu is-linux
use configurations.nu is-nixos

# View generations
def main [] {
  if (is-nixos) {
    nix-env --list-generations
  } else if (is-linux) {
    nixos-rebuild list-generations --json
    | from json
    | reject specialisations configurationRevision
    | table --index false
  } else {
    sudo /run/current-system/sw/bin/darwin-rebuild --list-generations
  }
}
