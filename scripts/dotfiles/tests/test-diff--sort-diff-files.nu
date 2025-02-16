use std assert

use ../diff.nu sort-diff-files

let a = "configuration/systems/darwin/configuration.nix -> configuration/systems/darwin/hosts/benrosen/configuration.nix"
let b = "configuration/home.nix -> configuration/systems/darwin/hosts/benrosen/home.nix"

assert equal (sort-diff-files $a $b false) false
assert equal (sort-diff-files $a $b true) true
assert equal (sort-diff-files $b $a false) true
assert equal (sort-diff-files $b $a true) false
