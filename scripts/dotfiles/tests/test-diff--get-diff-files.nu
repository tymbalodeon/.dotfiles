use std assert

use ../diff.nu get-diff-files

let target_files = [
  configuration/systems/nixos/hosts/bumbirich/home.nix
]

let actual_diff_files = (get-diff-files $target_files configuration/home.nix)

let expected_diff_files = [
  [source_file target_file];
  [
    configuration/home.nix
    configuration/systems/nixos/hosts/bumbirich/home.nix
  ]
]

assert equal $actual_diff_files $expected_diff_files

let actual_diff_files = (get-diff-files [] configuration/home.nix)

assert equal $actual_diff_files []
