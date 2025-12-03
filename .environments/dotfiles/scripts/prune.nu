#!/usr/bin/env nu

use configurations.nu is-nixos

# Collect garbage and remove old generations
export def main [
  --all # Remove all old generations
  --older-than: string # Remove generations older than this amount
] {
  let is_nixos = (is-nixos)

  if $is_nixos {
    let generations = if ($older_than | is-not-empty) {
      $older_than
    } else if $all {
      "old"
    } else {
      ""
    }

    if ($generations | is-not-empty) {
      nix-env --delete-generations $generations
    }
  }

  let args = [nix-collect-garbage]

  let args = if $is_nixos {
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
