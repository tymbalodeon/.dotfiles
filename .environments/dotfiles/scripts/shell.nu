#!/usr/bin/env nu

# Open Nix REPL with flake loaded
def main [] {
  nix repl --file configuration/flake.nix
}
