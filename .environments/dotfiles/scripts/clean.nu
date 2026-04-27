#!/usr/bin/env nu

use configurations.nu is-nixos

# Clean up Nix (excluding direnv)
export def main [
  --keep-since = "3d" # At least keep gcroots and generations in this time range since now
] {
  if (is-nixos) {
    nix-env --delete-generations $keep_since

    # TODO: should this run on home-manager, too?
    sudo nix-collect-garbage --delete-older-than $keep_since
  }

  nix-collect-garbage --delete-older-than $keep_since
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

# Clean all profiles (including direnv)
def "main all" [
  --keep: string # At least keep this number of generations
  --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  nh clean all --optimise ...(get-args $keep $keep_since)
}

# Clean all old roots (excluding direnv)
def "main old" [] {
  if (is-nixos) {
    nix-env --delete-generations old
  }

  nix-collect-garbage --delete-old
}

# Clean the current user's profile (including direnv)
def "main user" [
  --keep: string # At least keep this number of generations
  --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  nh clean user --optimise ...(get-args $keep $keep_since)
}
