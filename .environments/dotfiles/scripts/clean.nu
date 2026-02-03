#!/usr/bin/env nu

use optimise.nu
use prune.nu

# Run `prune` and `optimise`
def main [
  --all # Remove all old generations
  --environments # Remove project-local environments
  --older-than: string # Remove generations older than this amount
] {
  if $environments {
    main environments
  }

  if $all {
    prune --all
  } else if not ($older_than | is-empty) {
    prune --older-than $older_than
  } else {
    prune
  }

  optimise
}

# Remove project-local environments
def "main environments" [] {
  prune --environments
}
