#!/usr/bin/env nu

def --wrapped main [...args: string] {
  (
    nix run nixpkgs#nixos-generators --
      --flake ./configuration#iso
      --format iso
      --out-link result
      ...$args
  )
}
