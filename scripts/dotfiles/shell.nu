#!/usr/bin/env nu

use ./hosts.nu get-configuration

# Open Nix REPL with flake loaded
def main [
    host?: string # The target host configuration (auto-detected if not specified)
] {
  let configuration = (get-configuration $host)

  nix --extra-experimental-features repl-flake repl $configuration
}
