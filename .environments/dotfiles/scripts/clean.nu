#!/usr/bin/env nu

use configurations.nu is-nixos

# Clean up Nix (excluding local project environments)
export def main [
  --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  if (is-nixos) {
    let generations = if ($keep_since | is-not-empty) {
      $keep_since
    } else {
      "old"
    }

    if ($generations | is-not-empty) {
      nix-env --delete-generations $generations
    }
  }

  let args = [nix-collect-garbage]

  let args = if ($keep_since | is-not-empty) {
    $args
    | append [--delete-older-than $keep_since]
  } else {
    $args
    | append "--delete-old"
  }

  for command in [
    $args
    ($args | prepend sudo)
  ] {
    run-external $command
  }
}

def get-args [keep?: string keep_since?: string] {
  let args = []

  let args = if ($keep | is-not-empty) {
    $args
    | append [--keep $keep]
  } else {
    $args
  }

  let args = if ($keep_since | is-not-empty) {
    $args
    | append [--keep-since $keep_since]
  } else {
    $args
  }

  $args
}

# Clean all profiles (including local project environments)
def "main all" [
 --keep: string # At least keep this number of generations
 --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  nh clean all --optimise ...(get-args $keep $keep_since)
}

# Clean the current user's profile
def "main user" [
 --keep: string # At least keep this number of generations
 --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  nh clean user --optimise ...(get-args $keep $keep_since)
}
