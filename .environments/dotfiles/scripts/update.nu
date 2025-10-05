#!/usr/bin/env nu

use configurations.nu is-nixos
use configurations.nu is-linux

# Update dependencies
export def main [
  ...inputs: string # Inputs to update (see `inputs`)
] {
  let inputs = if ($inputs | is-empty) {
    let inputs = (
      nix flake info --json
      | from json
      | get locks.nodes.root.inputs
      | columns
    )

    let darwin_inputs = (
      $inputs
      | where {$in not-in [nixgl solaar]}
    )

    let linux_inputs = (
      $inputs
      | where {
          $in not-in [
            nix-darwin
            # TODO: remove when kitty > 0.42.1 works on Darwin
            nixpkgs-kitty
          ]
        }
    )

    let nixos_inputs = (
      $linux_inputs
      | where {$in != nixgl}
    )

    if (is-nixos) {
      nix flake update ...$nixos_inputs
    } else if (is-linux) {
      nix flake update ...$linux_inputs
    } else {
      nix flake update ...$darwin_inputs
    }
  } else {
    for input in $inputs {
      nix flake update $input
    }
  }
}
