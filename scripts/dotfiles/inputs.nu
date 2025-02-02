#!/usr/bin/env nu

# List flake inputs
def main [] {
  nix flake metadata --json
  | from json
  | get locks.nodes.root.inputs
  | columns
  | str join "\n"
}
