#!/usr/bin/env nu

# Replace identical files in the Nix store by hard links
export def main [] {
  nix store optimise
}
