#!/usr/bin/env nu

use ../environment.nu get-project-path
use ./hosts.nu get-available-hosts
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
    --hosts # The available hosts on the current system
    --older-than # (with `--clean` or `--prune`)
    --optimise # Run `just optimise` after rebuilding
    --prune # Run `just prune` after rebuilding
    --test # Apply the configuration without adding it to the boot menu
    --update # Update the flake lock before rebuilding
] {
  if $update {
    update
  }

  let is_nixos = (is-nixos)

  if $hosts {
    let hosts = if $is_nixos {
      get-available-hosts | get NixOS
    } else {
      get-available-hosts | get Darwin
    }

    return ($hosts | to text)
  }

  let host = if ($host | is-empty) {
    get-built-host-name
  } else {
    $host
  }

  let host = $"(get-project-path configuration)#($host)"

  git add .

  if $is_nixos {
    if $test {
        sudo nixos-rebuild test --flake $host
    } else {
        sudo nixos-rebuild switch --flake $host
    }
  } else {
    home-manager switch --flake $host
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
