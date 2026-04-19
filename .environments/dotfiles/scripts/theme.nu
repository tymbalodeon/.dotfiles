#!/usr/bin/env nu

use rebuild.nu
use theme-lib.nu get-built-theme
use theme-lib.nu get-theme
use theme-lib.nu stylix-theme-path
use theme-lib.nu theme-preview

def main [] {
  get-built-theme
}

def "main clear" [] {
  rm --force (stylix-theme-path)  
}

# List available themes
def "main list" [] {
  get-themes
  | get name
  | to text --no-newline
}

# Preview theme
def "main preview" [
  theme?: string
  --dark # Select dark themes only
  --light # Select light themes only
  --random # Select a random theme
] {
  theme-preview $dark $light $random $theme
}

# Rebuild with a new theme
def "main switch" [
  theme?: string
  --dark # Select dark themes only
  --force # Skip confirmation
  --light # Select light themes only
  --random # Select a random theme
] {
  let theme = (get-theme $dark $light $random $theme)

  if ($theme | is-empty) {
    return
  }

  if $random {
    tinty info $theme
  }

  if not $random or $force or (
    input "Are you sure you want to apply this theme? [y/N] "
    | str downcase
  ) in [yes y] {
    rebuild --theme (get-stylix-theme-name $theme)
  }
}
