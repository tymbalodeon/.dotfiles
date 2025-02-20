use std assert

use ../diff.nu list-files

def open-mock [filename: string] {
  open ([$env.FILE_PWD mocks $filename] | path join)
  | str trim
}

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

let tests = [
  {
    expected: (open-mock diff--list-files.txt)
    actual: (list-files $source_files $target_files false)
  }

  {
    expected: (open-mock diff--list-files--sort-by-target.txt)
    actual: (list-files $source_files $target_files true)
  }

  {
    expected: (open-mock diff--list-files--file.txt)
    actual: (list-files $source_files $target_files false configuration.nix)
  }

  {
    expected: (open-mock diff--list-files--file--sort-by-target.txt)
    actual: (list-files $source_files $target_files true home.nix)
  }
]

for test in $tests {
  assert equal $test.actual $test.expected
}
