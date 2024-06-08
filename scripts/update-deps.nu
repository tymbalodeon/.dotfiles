#!/usr/bin/env nu

use ./hosts.nu is_nixos

# Update dependencies
export def main [
    ...inputs: string # Inputs to update
    --all # Update all inputs, including for other hosts
    --list-inputs # List flake inputs
] {
    if $list_inputs {
        return (
            nix flake metadata --json
            | from json
            | get locks
            | get nodes
            | get root
            | get inputs
            | values
            | to text
        )
    }

    if $all {
        nix flake update
    } else {
        mut inputs = if ($inputs | is-empty) {
            mut inputs = ["home-manager" "nushell-syntax"]

            if (is_nixos) {
                $inputs | append ["nixpkgs"]
            } else {
                $inputs | append ["nixpkgs-darwin" "nixpkgs-elm"]
            }
        } else {
            $inputs
        }

        for input in $inputs {
            nix flake update $input
        }
    }
}
