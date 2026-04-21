#!/usr/bin/env nu

use configurations.nu get-all-hosts
use configurations.nu get-built-host-name
use configurations.nu is-home-manager
use configurations.nu is-nixos
use optimise.nu
use prune.nu
use theme-lib.nu get-built-theme
use theme-lib.nu get-env-values
use theme-lib.nu get-stylix-theme-name
use theme-lib.nu get-theme
use theme-lib.nu set-built-theme
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

def xdg-state-home [] {
  try {
    $env.XDG_STATE_HOME
  } catch {
    $env.HOME
    | path join .local/state
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
  --default-theme # Ignore $XDG_STATE_HOME/stylix-theme value and build with default theme
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
  let env_values = (get-env-values)

  let dark_theme = (
    $dark_theme or $env_values.random_theme and $env_values.dark_theme
  )

  let light_theme = (
    $light_theme or $env_values.random_theme and $env_values.light_theme
  )

  let random_theme = if ($random_theme | is-empty) {
    $env_values.random_theme
  } else {
    $random_theme
  }

  let theme = if not $default_theme and (
    [$choose_theme $dark_theme $light_theme $random_theme $theme]
    | all {|item| ($item | is-empty) or ($item == false)}
  ) {
    let theme = (get-built-theme)

    if ($theme | is-not-empty) {
      let info = $"(ansi default_bold)info(ansi reset)"

      print $"($info): Using previously built theme \"($theme)\""
      print $"($info): Use `--default-theme` to build with the default theme"
    }

    $theme
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

  if $random_theme {
    tinty info $theme
  }

  if ($theme | is-not-empty) {
    $env.STYLIX_THEME = (get-stylix-theme-name $theme)
  }

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

  set-built-theme $theme

  # TODO: update wallpaper fill color to match new theme here!
  # FIXME: this doesn't work!
  let ls_colors = try { nu -c "vivid generate stylix" }

  if ($ls_colors | is-not-empty) {
    $ls_colors
    | save --force (xdg-state-home | path join ls-colors)
  }

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
