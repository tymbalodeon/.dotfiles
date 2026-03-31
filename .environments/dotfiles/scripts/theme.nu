#!/usr/bin/env nu

use rebuild.nu
use theme-preview.nu
use theme-preview.nu get-theme
use theme-preview.nu get-themes

def main [] {}

# List available themes
def "main list" [] {
  get-themes
  | get name
  | to text --no-newline
}

def get-random-theme [variant?: string] {
  let themes = (get-themes $variant)

  let theme = (
    $themes
    | get (random int 0..($themes | enumerate | get index | last))
    | get name
  )

  get-theme $theme
}

# TODO: allow displaying name and selecting id
def select-theme [variant?: string] {
  let themes = (get-themes $variant)

  $themes
  | get id
  | to text
  | fzf --preview "tinty info {}"
}

def get-variant [dark?: bool light?: bool] {
  if $dark {
    "dark"
  } else if $light {
    "light"
  } else {
    null
  }
}

# Preview theme
def "main preview" [
  theme?: string
  --dark # Select dark themes only
  --light # Select light themes only
] {
  theme-preview $theme $dark $light
}

# Preview a random theme
def "main preview random" [
  --dark # Select dark themes only
  --light # Select light themes only
] {
  tinty info (get-random-theme (get-variant $dark $light))
}

def get-stylix-theme-name [theme: string] {
  $theme
  | str replace base16- ""
}

# Rebuild with a new theme
def "main switch" [
  theme?: string
  --dark # Select dark themes only
  --light # Select light themes only
] {
  let theme = if ($theme | is-empty) {
    select-theme (get-variant $dark $light)
  } else {
    $theme
  }

  let theme = (get-theme $theme)

  if ($theme | is-empty) {
    return
  }

  rebuild --theme (get-stylix-theme-name $theme)
}

# Rebuild with  a random theme
def "main switch random" [
  --dark # Select dark themes only
  --force # Skip confirmation
  --light # Select light themes only
] {
  let theme = (get-random-theme (get-variant $dark $light))

  tinty info $theme

  if $force or (
    input "Are you sure you want to apply this theme? [y/N] "
    | str downcase
  ) in [yes y] {
    rebuild --theme (get-stylix-theme-name $theme)
  }
}
