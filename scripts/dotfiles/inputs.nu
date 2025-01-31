#!/usr/bin/env nu

# List flake inputs
def main [] {
  nix flake metadata --json
  | from json
  | get locks
  | get nodes
  | get root
  | get inputs
  | columns
  | str join "\n"
}
