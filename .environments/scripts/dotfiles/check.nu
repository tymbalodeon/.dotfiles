#!/usr/bin/env nu

# Check configuration flake
def --wrapped main [...$args: string] {
  nix flake check ...$args
}
