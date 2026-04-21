#!/usr/bin/env nu

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

# Clean up Nix (excluding local project environments)
export def main [
 --keep: string # At least keep this number of generations
 --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  nh clean all --optimise ...(get-args $keep $keep_since)
}

# Clean all profiles (including local project environments)
def "main all" [
 --keep: string # At least keep this number of generations
 --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  main environments
  nh clean all --optimise ...(get-args $keep $keep_since)
}

# Clean local project environments
export def "main environments" [] {
  for directory in (fd \.direnv$ --hidden --no-ignore $env.HOME | lines) {
    rm --force --recursive $directory
  }
}

# Clean the current user's profile
def "main user" [
 --keep: string # At least keep this number of generations
 --keep-since: string # At least keep gcroots and generations in this time range since now
] {
  nh clean user --optimise ...(get-args $keep $keep_since)
}
