#!/usr/bin/env nu

use configurations.nu get-built-host-name
use configurations.nu is-home-manager
use configurations.nu is-nixos

def shared-inputs [] {
  [
    base16-helix
    src
  ]
}

def home-manager-inputs [] {
  shared-inputs
  | append [
    home-manager-unstable
    nixgl
    nixpkgs-unstable
    stylix-unstable
  ]
}

def nixos-inputs [] {
  shared-inputs
  | append [
    home-manager-unstable
    musnix
    nixpkgs-unstable
    solaar
    stylix-unstable
    wayland-pipewire-idle-inhibit
  ]
}


# Update dependencies
export def main [
  ...inputs: string # Inputs to update (see `inputs`)
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

  nix flake update ...$inputs
}
