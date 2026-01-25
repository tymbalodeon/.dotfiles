#!/usr/bin/env nu

def main [] {}

def get-themes [] {
  tinty list --json
  | from json
  | where system == base16
}

# List available themes
def "main list" [] {
  get-themes
  | get name
  | to text
}

# Preview theme
def "main preview" [
  theme?: string
  --random # TODO
] {
  let themes = (get-themes)

  let theme = if ($theme | is-empty) {
    $themes
    | get name
    | to text
    | fzf
  } else {
    $theme
  }

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

  let theme = ($theme | first | get id)

  tinty info $theme
}

