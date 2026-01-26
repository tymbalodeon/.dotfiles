#!/usr/bin/env nu

use rebuild.nu

def main [] {}

def get-themes [variant?: string] {
  let themes = (
    tinty list --json
    | from json
    | where system == base16
  )

  if $variant == dark {
    $themes
    | where variant == dark
  } else if $variant == light {
    $themes
    | where variant == light
  } else {
    $themes
  }
}

# List available themes
def "main list" [] {
  get-themes
  | get name
  | to text
}

def get-theme [theme: string] {
  let themes = (get-themes)

  let theme = if ($theme | str starts-with base16-) {
    $themes
    | where id == ($theme | str downcase)
  } else {
    $themes
    | where name == $theme
  }

  if ($theme | is-empty) {
    return
  }

  $theme
  | first
  | get id
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
  let theme = if ($theme | is-empty) {
    select-theme (get-variant $dark $light)
  } else {
    $theme
  }

  let theme = (get-theme $theme)

  if ($theme | is-empty) {
    return
  }

  tinty info $theme
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
  --light # Select light themes only
] {
  let theme = (get-random-theme (get-variant $dark $light))

  rebuild --theme (get-stylix-theme-name $theme)
}
