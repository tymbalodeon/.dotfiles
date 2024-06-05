#!/usr/bin/env nu

# Update dependencies
export def main [
    ...inputs: string # Inputs to update
] {
    if ($inputs | is-empty) {
        nix flake update
    } else {
        for input in $inputs {
            nix flake update $input
        }
    }
}
