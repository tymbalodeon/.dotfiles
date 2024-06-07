#!/usr/bin/env nu

# Update dependencies
export def main [
    ...inputs: string # Inputs to update
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

    if ($inputs | is-empty) {
        nix flake update
    } else {
        for input in $inputs {
            nix flake update $input
        }
    }
}
