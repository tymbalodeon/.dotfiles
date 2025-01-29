#!/usr/bin/env nu

use ./hosts.nu is-nixos

def get-global-inputs [] {
    return ["nushell-syntax"]
}

def get-darwin-inputs [] {
    return (
        (get-global-inputs) ++ [
            "home-manager" "nixpkgs-darwin"
        ]
    )
}

def get-nixos-inputs [] {
    return ((get-global-inputs) ++ ["nixpkgs"])
}

def get-input-status [system: string input: string] {
    let global_inputs = (get-global-inputs)

    let system_inputs = {
        "darwin": (get-darwin-inputs)
        "nixos": (get-nixos-inputs)
    }

    let is_nixos = (is-nixos)

    let is_system_match = (
        ($is_nixos and $system == "nixos")
        or (not $is_nixos and $system == "darwin")
    )

    let green = if $is_system_match {
        (ansi lgb)
    } else {
        (ansi gd)
    }

    let red = if $is_system_match {
        (ansi lrb)
    } else {
        (ansi rd)
    }

    if ($input in ($system_inputs | get $system)) {
        return $"($green)✓(ansi reset)"
    } else {
        return $"($red)✗(ansi reset)"
    }
}

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
            | transpose input darwin
            | each {
                |input|

                $input
                | update darwin (get-input-status "darwin" $input.input)
            }
            | insert nixos ""
            | each {
                |input|

                $input
                | update nixos (get-input-status "nixos" $input.input)
            }
            | table --index false
        )
    }

    if $all {
        nix flake update
    } else {
        let is_nixos = (is-nixos)

        mut inputs = if ($inputs | is-empty) {
            if $is_nixos {
                get-nixos-inputs
            } else {
                get-darwin-inputs
            }
        } else {
            $inputs
        }

        for input in $inputs {
            nix flake update $input
        }
    }
}
