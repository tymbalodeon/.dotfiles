#!/usr/bin/env nu

use configurations.nu get-all-hosts
use configurations.nu get-built-host-name
use configurations.nu is-linux
use configurations.nu is-nixos
use prune.nu
use optimise.nu
use update.nu

def --wrapped darwin-rebuild [...$args: string] {
  try {
    sudo /run/current-system/sw/bin/darwin-rebuild ...$args
  } catch {
    sudo nix run "nix-darwin/master#darwin-rebuild" -- ...$args
  }
}

# Rebuild and switch to (or --test) a configuration
def main [
    host?: string # The target host configuration (auto-detected if not specified)
    --clean # Run `just prune` and `just optimise` after rebuilding
    --clean-all # Clean, removing all old generations
    --debug # Run and show verbose trace
    --older-than: string # (with `--clean` or `--prune`)
    --optimise # Run `just optimise` after rebuilding
    --prune # Run `just prune` after rebuilding
    --prune-all # Prune, removing all old generations
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
    # TODO: is there a --debug here? If not, make a note in the help text above
    if $test {
        sudo nixos-rebuild test --flake $host
    } else {
        sudo nixos-rebuild switch --flake $host
    }
  } else if (is-linux) {
    # TODO: handle what to do if home-manager is not yet installed. Does this
    # apply to darwin too?
    if $debug {
      home-manager switch --flake $host --show-trace --verbose
    } else {
      home-manager switch --flake $host
    }
  } else {
    if $debug {
      darwin-rebuild switch --flake $host --show-trace --verbose
    } else {
      darwin-rebuild switch --flake $host
    }
  }

  bat cache --build

  if $clean or $clean_all or $prune or $prune_all {
    if $clean_all or $prune_all {
      prune --all
    } else if not ($older_than | is-empty) {
      prune --older-than $older_than
    } else {
      prune
    }
  }

  if $clean or $clean_all or $optimise {
    optimise
  }

  if not (git status --short | is-empty) {
    git status
  }
}
