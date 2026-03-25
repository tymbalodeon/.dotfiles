#!/usr/bin/env nu

use configurations.nu get-built-host-name
use configurations.nu is-darwin
use configurations.nu is-home-manager
use configurations.nu is-nixos

def shared-inputs [] {
  [
    base-16-helix
    src
  ]
}

def darwin-unstable-inputs [] {
  shared-inputs
  | append [
    home-manager-unstable
    nix-darwin-unstable
    nixpkgs-unstable
    stylix-unstable
  ]
}

def darwin-25_05-inputs [] {
  shared-inputs
  | append [
    home-manager-25_05
    nix-darwin-25_05
    nixpkgs-25_05
    stylix-25_05
  ]
}

def harzima-inputs [] {
  darwin-25_05-inputs
  | append [tsundeoku]
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
    if (is-darwin) {
      if (get-built-host-name) == harzima {
        harzima-inputs
      } else {
        darwin-unstable-inputs
      }
    } else if (is-home-manager) {
      home-manager-inputs
    } else if (is-nixos) {
      nixos-inputs
    }
  } else {
    $inputs
  }

  nix flake update ...$inputs
}
