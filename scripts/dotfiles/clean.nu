#!/usr/bin/env nu

use optimise.nu
use prune.nu

# Run `prune` and `optimise`
def main [
  --all # Remove all old generations
  --older-than: string # Remove generations older than this amount
] {
  if $all {
    prune --all
  } else if not ($older_than | is-empty) {
    prune --older-than $older_than
  } else {
    prune
  }

  optimise
}
