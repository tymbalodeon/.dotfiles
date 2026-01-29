#!/usr/bin/env nu

use configurations.nu is-nixos

# Collect garbage and remove old generations
export def main [
  --all # Remove all old generations
  --environments # Remove project-local environments
  --older-than: string # Remove generations older than this amount
] {
  if $environments {
    main environments
  }

  if (is-nixos) {
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

  let args = if $all {
    $args
    | append "--delete-old"
  } else if not ($older_than | is-empty) {
    $args
    | append [--delete-older-than $older_than]
  } else {
    $args
  }

  for command in [
    $args
    ($args | prepend sudo)
  ] {
    run-external $command
  }
}

def "main environments" [] {
  for directory in (fd \.direnv$ --hidden --no-ignore $env.HOME | lines) {
    rm --force --recursive $directory
  }
}
