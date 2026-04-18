#!/usr/bin/env nu

use configurations.nu get-all-hosts
use configurations.nu get-built-host-name
use configurations.nu is-home-manager
use configurations.nu is-nixos
use optimise.nu
use prune.nu
use theme-preview.nu get-stylix-theme-name
use theme-preview.nu get-theme
use update.nu

def darwin-rebuild [
  host: string
  debug: bool
] {
  let command = if (
    which /run/current-system/sw/bin/darwin-rebuild
    | is-empty
  ) {
    "nix run 'nix-darwin/master#darwin-rebuild' --"
  } else {
    "/run/current-system/sw/bin/darwin-rebuild"
  }

  let args = [switch --flake $host --impure]

  let args = if $debug {
    $args
    | append [--show-trace --verbose]
  } else {
    $args
  }

  sudo --preserve-env="STYLIX_THEME" $command ...$args
}

def nixos-rebuild [
  host: string
  test: bool
] {
  let args = [--flake $host --impure]

  let args = if $test {
    $args
    | append test
  } else {
    $args
    | append switch
  }

  sudo --preserve-env="STYLIX_THEME" nixos-rebuild ...$args
}

def home-manager [
  host: string
  debug: bool
] {
  let args = [switch --flake $host]

  let args = if $debug {
    $args
    | append [--show-trace --verbose]
  } else {
    $args
  }

  if (^which home-manager | is-empty) {
    nix run home-manager/master -- ...$args
  } else {
    ^home-manager ...$args
  }
}

def "tinty list" [] {
  try {
    ^tinty list out+err> /dev/null
  } catch {
    tinty install
  }

  ^tinty list --json
  | from json
  | where {$in.system == base16}
}

def get-env-value [values: table<key: string, value: string> key: string] {
  $values
  | where key == $key
  | get value
  | first
}

def get-env-theme [] {
  try {
    let values = (open ../.env | parse "{key}={value}")
    let theme = try { get-env-value $values STYLIX_THEME }
    let variant = try { get-env-value $values STYLIX_VARIANT }

    let dark_theme = if ($variant | is-empty) {
      false
    } else {
      ($variant | str downcase) == dark
    }

    let light_theme = if ($variant | is-empty) {
      false
    } else {
      ($variant | str downcase) == light
    }
   
    {
      theme: $theme
      dark_theme: $dark_theme
      light_theme: $light_theme
    }
  } catch {
    {
      theme: null
      dark_theme: null
      light_theme: null
    }
  }
}

# Rebuild and switch to (or --test) a configuration
export def main [
    host?: string # The target host configuration (auto-detected if not specified)
    --choose-theme # Choose the stylix theme interactively
    --clean # Run `just prune` and `just optimise` after rebuilding
    --clean-all # Clean, removing all old generations
    --dark-theme # Select only dark themes
    --debug # Run and show verbose trace
    --light-theme # Select only light themes
    --older-than: string # (with `--clean` or `--prune`)
    --optimise # Run `just optimise` after rebuilding
    --prune # Run `just prune` after rebuilding
    --prune-all # Prune, removing all old generations
    --random-theme # Select a random stylix theme
    --test # Apply the configuration without adding it to the boot menu
    --theme: string # Override the stylix theme
    --update # Update the flake lock before rebuilding
] {
  let env_theme = (get-env-theme)

  let dark_theme = if ($dark_theme | is-empty) {
    $env_theme.dark_theme
  } else {
    $dark_theme
  }

  let light_theme = if ($light_theme | is-empty) {
    $env_theme.light_theme
  } else {
    $light_theme
  }

  let random_theme = (
    $random_theme or ($env_theme.theme | str downcase) == random
  )

  let theme = if (
    [$choose_theme $dark_theme $light_theme $random_theme $theme]
    | all {|item| ($item | is-empty) or ($item == false)}
  ) {
    $env_theme.theme
  } else {
    $theme
  }

  let theme = if not (
    [
      $choose_theme
      $dark_theme
      $light_theme
      $random_theme
      $theme
    ] | each {
        |item|

        ($item | is-not-empty) and ($item != false)
      } | any {into bool}) {
    null
  } else {
    get-theme $dark_theme $light_theme $random_theme $theme
  }

  let theme = (get-stylix-theme-name $theme)

  if $random_theme {
    tinty info $theme
  }

  $env.STYLIX_THEME = $theme

  if $update {
    update
  }

  let host = if ($host | is-empty) {
    get-built-host-name
  } else {
    $host
  }

  let host = $".#($host)"

  git add .

  if (is-nixos) {
    # TODO: is there a --debug here? If not, make a note in the help text above
    nixos-rebuild $host $test
  } else if (is-home-manager) {
    # TODO: handle what to do if home-manager is not yet installed. Does this
    # apply to darwin too?
    home-manager $host $debug
  } else {
    darwin-rebuild $host $debug
  }

  $env.LS_COLORS
  | save --force ($env.XDG_STATE_HOME | path join ls-colors)

  bat cache --build

  if $clean or $clean_all or $prune or $prune_all {
    if $clean_all or $prune_all {
      prune --all
    } else if not ($older_than | is-empty) {
      prune --older-than $older_than
    } else {
      prune
    }
  }

  if $clean or $clean_all or $optimise {
    optimise
  }

  if not (git status --short | is-empty) {
    git status
  }
}
