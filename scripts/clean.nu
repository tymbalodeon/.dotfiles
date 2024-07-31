#!/usr/bin/env nu

use ./optimise.nu
use ./prune.nu

# Run `prune` and `optimise`
export def main [
  --all
] {
  if $all {
    prune --all
  } else {
    prune
  }

  optimise
}
