#!/usr/bin/env nu

use configurations.nu get-all-hosts
use configurations.nu get-built-host-name
use configurations.nu is-linux
use configurations.nu is-nixos
use extensions.nu
use prune.nu
use optimise.nu
use update.nu

def darwin-rebuild [
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

  if (which /run/current-system/sw/bin/darwin-rebuild | is-empty) {
    sudo nix run "nix-darwin/master#darwin-rebuild" -- ...$args
  } else {
    sudo /run/current-system/sw/bin/darwin-rebuild ...$args
  }
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
  let theme = if ($theme | is-not-empty)  {
    $theme
  } else {
    if not $choose_theme and not $random_theme {
      $theme
    } else {
      let themes = (
        tinty list --json
        | from json
        | where {$in.system == base16}
      )

      let themes = if $dark_theme  {
        $themes
        | where variant == dark
      } else if $light_theme {
        $themes
        | where variant == light
      } else {
        $themes
      }

      let themes = $themes.id

      let theme = if $choose_theme {
        $themes
        | to text
        | fzf
      } else if $random_theme {
        let index = (random int 0..($themes | length))

        $themes
        | get $index
      }

      $theme
      | str replace base16- ""
    }
  }

  $env.STYLIX_THEME = $theme

  if $update {
    extensions
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
  } else if (is-linux) {
    # TODO: handle what to do if home-manager is not yet installed. Does this
    # apply to darwin too?
    home-manager $host $debug
  } else {
    darwin-rebuild $host $debug
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
