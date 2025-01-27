#!/usr/bin/env nu

use ../environment.nu get-project-path
use ./hosts.nu get_available_hosts
use ./hosts.nu get_built_host_name
use ./hosts.nu is_nixos
use ./prune.nu
use ./optimise.nu
use ./update.nu

# Rebuild and switch to (or --test) a configuration
def main [
    host?: string # The target host configuration (auto-detected if not specified)
    --clean # Run `just prune` and `just optimise` after rebuilding
    --hosts # The available hosts on the current system
    --optimise # Run `just optimise` after rebuilding
    --prune # Run `just prune` after rebuilding
    --test # Apply the configuration without adding it to the boot menu
    --update # Update the flake lock before rebuilding
] {
  if $update {
    update
  }

  let is_nixos = (is_nixos)

  if $hosts {
    let hosts = if $is_nixos {
      get_available_hosts | get NixOS
    } else {
      get_available_hosts | get Darwin
    }

    return ($hosts | to text)
  }

  let host = if ($host | is-empty) {
    get_built_host_name
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
    prune
  }

  if $clean or $optimise {
    optimise
  }

  if not (git status --short | is-empty) {
    git status
  }
}
