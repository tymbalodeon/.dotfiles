#!/usr/bin/env nu

use configurations.nu is-nixos

# Collect garbage and remove old generations
export def main [
  --all # Remove all old generations
  --older-than: string # Remove generations older than this amount
] {
  let args = [nix-collect-garbage]

  let args = if (is-nixos) {
    $args
    | prepend sudo
  } else {
    $args
  }

  let args = if $all {
    $args
    | append "--delete-old"
  } else if not ($older_than | is-empty) {
    $args
    | append [--delete-older-than $older_than]
  } else {
    $args
  }

  run-external $args
}
