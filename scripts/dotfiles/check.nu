#!/usr/bin/env nu

# Check configuration flake
def main [] {
  nix flake check
}
