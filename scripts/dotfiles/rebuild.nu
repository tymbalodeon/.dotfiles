#!/usr/bin/env nu

use ./hosts.nu get-all-hosts
use ./hosts.nu get-built-host-name
use ./hosts.nu is-nixos
use ./prune.nu
use ./optimise.nu
use ./update.nu


# Rebuild and switch to (or --test) a configuration
def main [
    host?: string # The target host configuration (auto-detected if not specified)
    --all # (with `--clean` or `--prune`)
    --clean # Run `just prune` and `just optimise` after rebuilding
    --debug # Run and show verbose trace
    --older-than: string # (with `--clean` or `--prune`)
    --optimise # Run `just optimise` after rebuilding
    --prune # Run `just prune` after rebuilding
    --test # Apply the configuration without adding it to the boot menu
    --update # Update the flake lock before rebuilding
] {
  if $update {
    update
  }

  let host = if ($host | is-empty) {
    get-built-host-name
  } else {
    $host
  }

  let host = $".#($host)"

  git add .

  if (is-nixos) {
    if $test {
        sudo nixos-rebuild test --flake $host
    } else {
        sudo nixos-rebuild switch --flake $host
    }
  } else {
    if $debug {
      /run/current-system/sw/bin/darwin-rebuild switch --flake $host --show-trace --verbose
    } else {
      /run/current-system/sw/bin/darwin-rebuild switch --flake $host
    }
  }

  rustup update

  bat cache --build

  if $clean or $prune {
    if $all {
      prune --all
    } else if not ($older_than | is-empty) {
      prune --older-than $older_than
    } else {
      prune
    }
  }

  if $clean or $optimise {
    optimise
  }

  if not (git status --short | is-empty) {
    git status
  }
}
