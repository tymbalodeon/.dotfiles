#!/usr/bin/env nu

use ./hosts.nu is_nixos

def get_input_status [system: string input: string] {
    let global_inputs = ["home-manager" "nushell-syntax"]

    let system_inputs = {
        "darwin": ($global_inputs ++ ["nixpkgs-darwin" "nixpkgs-elm"])
        "nixos": ($global_inputs ++ ["nixpkgs"])
    }

    let is_nixos = (is_nixos)

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
                | update darwin (get_input_status "darwin" $input.input)
            }
            | insert nixos ""
            | each {
                |input| 

                $input 
                | update nixos (get_input_status "nixos" $input.input)
            }
            | table --index false
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
            nix flake lock --update-input $input
        }
    }
}
