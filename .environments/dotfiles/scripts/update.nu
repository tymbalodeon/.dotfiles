#!/usr/bin/env nu

use configurations.nu get-built-host-name
use configurations.nu is-home-manager
use configurations.nu is-nixos

def shared-inputs [] {
  [
    home-manager
    nixgl
    nix-index-database
    nixpkgs
    src
    zk-graph
  ]
}

def home-manager-inputs [] {
  shared-inputs
  | append [
    stylix
  ]
}

def nixos-inputs [] {
  shared-inputs
  | append [
    base16-helix
    musnix
    solaar
    stylix
    wayland-pipewire-idle-inhibit
  ]
}

# Update dependencies
export def main [
  ...inputs: string # Inputs to update (see `inputs`)
  --nixpkgs # Update nixpkgs as well as other inputs
] {
  let inputs = if ($inputs | is-empty) {
    if (is-home-manager) {
      home-manager-inputs
    } else if (is-nixos) {
      nixos-inputs
    }
  } else {
    $inputs
  }

  let inputs = if $nixpkgs {
    $inputs
  } else {
    $inputs
    | where $it != nixpkgs
  }

  nix flake update ...$inputs
}

# Update all dependencies
def "main all" [] {
  nix flake update
}
