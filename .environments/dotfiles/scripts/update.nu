#!/usr/bin/env nu

use configurations.nu is-nixos
use configurations.nu is-linux

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

    if ((uname).kernel-name == Darwin) {
      let darwin_inputs = (
        $inputs
        | where {
            $in not-in [
              nixgl
              wayland-pipewire-idle-inhibit
            ]
          }
      )

      nix flake update ...$darwin_inputs
    } else if (is-linux) {
      let linux_inputs = (
        $inputs
        | where {$in !~ nix-darwin}
      )

      if (is-nixos) {
        let nixos_inputs = (
          $linux_inputs
          | where {$in != nixgl}
        )
        
        nix flake update ...$nixos_inputs
      } else {
        nix flake update ...$linux_inputs
      }
    }
  } else {
    for input in $inputs {
      nix flake update $input
    }
  }
}
