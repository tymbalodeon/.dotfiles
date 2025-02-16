use std assert

use ../diff.nu get-diff-files

let source_files = [
  configuration/bat/config
  configuration/flake.lock
  configuration/flake.nix
  configuration/git/.gitconfig
  configuration/helix/config.toml
  configuration/helix/languages.toml
  configuration/helix/themes/theme.toml
  configuration/home.nix
  configuration/jj/config.toml
  configuration/kitty/theme.conf
  configuration/nushell/aliases.nu
  configuration/nushell/cloud.nu
  configuration/nushell/colors.nu
  configuration/nushell/config.nu
  configuration/nushell/env.nu
  configuration/nushell/f.nu
  configuration/nushell/prompt.nu
  configuration/nushell/src.nu
  configuration/nushell/theme.nu
  configuration/nushell/themes.toml
  configuration/systems/darwin/.hushlogin
  configuration/systems/darwin/configuration.nix
  configuration/systems/darwin/home.nix
  configuration/systems/darwin/nushell/theme-function.nu
  configuration/systems/darwin/rustup/settings.toml
  configuration/systems/darwin/tinty/fzf.toml
  configuration/tealdeer/config.toml
  configuration/tinty/helix.toml
  configuration/tinty/kitty.toml
  configuration/tinty/shell.toml
  configuration/vivid/themes/theme.yml
  configuration/zellij/themes/theme.kdl
]

let target_files = [
  configuration/systems/darwin/hosts/benrosen/configuration.nix
  configuration/systems/darwin/hosts/benrosen/home.nix
]


let actual_diff_files = (get-diff-files $source_files $target_files)

let expected_diff_files = [
  [source_file target_file];
  [
    configuration/home.nix
    configuration/systems/darwin/hosts/benrosen/home.nix
  ]
  [
    configuration/systems/darwin/configuration.nix
    configuration/systems/darwin/hosts/benrosen/configuration.nix
  ]
  [
    configuration/systems/darwin/home.nix
    configuration/systems/darwin/hosts/benrosen/home.nix
  ]
]

assert equal $actual_diff_files $expected_diff_files

let actual_diff_files = (get-diff-files $source_files $target_files home.nix)

let expected_diff_files = [
  [source_file target_file];
  [
    configuration/home.nix
    configuration/systems/darwin/hosts/benrosen/home.nix
  ]
  [
    configuration/systems/darwin/home.nix
    configuration/systems/darwin/hosts/benrosen/home.nix
  ]
]

assert equal $actual_diff_files $expected_diff_files

let actual_diff_files = (
  get-diff-files $source_files $target_files zellij/themes/theme.kdl
)

assert equal $actual_diff_files []
