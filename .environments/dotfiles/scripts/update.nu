#!/usr/bin/env nu

use configurations.nu get-built-host-name
use configurations.nu is-darwin
use configurations.nu is-home-manager
use configurations.nu is-nixos

def darwin-unstable-inputs [] {
  [
    home-manager-unstable
    nix-darwin-unstable
    nixpkgs-unstable
    src
    stylix-unstable
  ]
}

def darwin-25_05-inputs [] {
  [
    home-manager-25_05
    nix-darwin-25_05
    nixpkgs-25_05
    src
    stylix-25_05
  ]
}

def harzima-inputs [] {
  [tsundeoku]
}

def home-manager-inputs [] {
  [
    home-manager-unstable
    nixgl
    nixpkgs-unstable
    src
    stylix-unstable
  ]
}

def nixos-inputs [] {
  [
    home-manager-unstable
    nixpkgs-unstable
    solaar
    src
    stylix-unstable
    wayland-pipewire-idle-inhibit
  ]
}


# Update dependencies
export def main [
  ...inputs: string # Inputs to update (see `inputs`)
] {
  let inputs = if ($inputs | is-empty) {
    let inputs = (
      nix flake metadata --json
      | from json
      | get locks.nodes.root.inputs
      | columns
    )

    if (is-darwin) {
      let inputs = (darwin-unstable-inputs)

      if (get-built-host-name) == harzima {
        $inputs
        | append (harzima-inputs)
      } else {
        $inputs
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
