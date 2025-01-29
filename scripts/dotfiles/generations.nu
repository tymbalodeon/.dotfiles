#!/usr/bin/env nu

use ./hosts.nu is-nixos

# View generations
def main [] {
  if (is-nixos) {
    nixos-rebuild list-generations --json
    | from json
    | reject specialisations configurationRevision
    | table --index false
  } else {
    try {
      home-manager generations
    }
  }
}
