#!/usr/bin/env nu

use clean.nu
use configurations.nu get-all-hosts
use configurations.nu get-built-host-name
use configurations.nu is-home-manager
use configurations.nu is-nixos
use ../../default/scripts/print.nu print-error
use theme-lib.nu get-built-theme
use theme-lib.nu get-env-values
use theme-lib.nu get-stylix-theme-name
use theme-lib.nu get-theme
use theme-lib.nu set-built-theme
use update.nu

def xdg-state-home [] {
  try {
    $env.XDG_STATE_HOME
  } catch {
    $env.HOME
    | path join .local/state
  }
}

# TODO: create a separate function for testing (`nh test`)
# Switch to the current state of the configuration files
export def main [
  host?: string # The target host configuration (auto-detected if not specified)
  --choose-theme # Choose the stylix theme interactively
  --clean # Run `clean` after rebuilding
  --dark-theme # Select only dark themes
  --debug # Run and show verbose trace
  --default-theme # Ignore $XDG_STATE_HOME/stylix-theme value and build with default theme
  --light-theme # Select only light themes
  --random-theme # Select a random stylix theme
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
    let found_theme = (get-theme $dark_theme $light_theme $random_theme $theme)

    if ($found_theme | is-empty) {
      print-error $"theme \"($theme)\" not found"

      return
    } else {
      $found_theme
    }
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

  git add .

  if (is-nixos) {
    nh os switch . --hostname $host --impure
  } else if (is-home-manager) {
    nh home switch . --configuration $host --impure
  } else {
    nh darwin switch . --hostname $host --impure
  }

  if (get-built-theme) != $theme {
    set-built-theme $theme
    systemctl --user restart waybar
  }

  # TODO: update wallpaper fill color to match new theme here!
  # FIXME: this doesn't work!
  let ls_colors = try { nu -c "vivid generate stylix" }

  if ($ls_colors | is-not-empty) {
    $ls_colors
    | save --force (xdg-state-home | path join ls-colors)
  }

  bat cache --build

  if $clean {
    clean --keep-since 3d
  }

  if not (git status --short | is-empty) {
    git status
  }
}
