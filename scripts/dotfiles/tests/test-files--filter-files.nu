use std assert

use ../files.nu filter-files

let files = [
  configuration/bat/config
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
  configuration/systems/darwin/hosts/benrosen/configuration.nix
  configuration/systems/darwin/hosts/benrosen/home.nix
  configuration/systems/darwin/hosts/work/configuration.nix
  configuration/systems/darwin/hosts/work/git/.gitconfig
  configuration/systems/darwin/hosts/work/home.nix
  configuration/systems/darwin/hosts/work/jj/config.toml
  configuration/systems/darwin/nushell/theme-function.nu
  configuration/systems/darwin/rustup/settings.toml
  configuration/systems/darwin/tinty/fzf.toml
  configuration/systems/nixos/configuration.nix
  configuration/systems/nixos/home.nix
  configuration/systems/nixos/hosts/bumbirich/configuration.nix
  configuration/systems/nixos/hosts/bumbirich/hardware-configuration.nix
  configuration/systems/nixos/hosts/bumbirich/home.nix
  configuration/systems/nixos/hosts/bumbirich/hypr/hyprland.conf
  configuration/systems/nixos/hosts/ruzia/configuration.nix
  configuration/systems/nixos/hosts/ruzia/hardware-configuration.nix
  configuration/systems/nixos/hosts/ruzia/home.nix
  configuration/systems/nixos/hypr/hyprland.conf
  configuration/systems/nixos/hypr/hyprpaper.conf
  configuration/systems/nixos/hypr/wallpaper/hildegard.jpeg
  configuration/systems/nixos/nushell/theme-function.nu
  configuration/systems/nixos/rofi/config.rasi
  configuration/systems/nixos/rustup/settings.toml
  configuration/systems/nixos/swaync/style.css
  configuration/systems/nixos/tinty/fzf.toml
  configuration/systems/nixos/tinty/rofi.toml
  configuration/systems/nixos/tinty/waybar.toml
  configuration/systems/nixos/waybar/colors.css
  configuration/systems/nixos/waybar/config.jsonc
  configuration/systems/nixos/waybar/style.css
  configuration/tealdeer/config.toml
  configuration/tinty/helix.toml
  configuration/tinty/kitty.toml
  configuration/tinty/shell.toml
  configuration/vivid/themes/theme.yml
  configuration/zellij/themes/theme.kdl
]

let system_names = [
  darwin
  nixos
]

let host_names = [
  benrosen
  work
  bumbirich
  ruzia
]

let tests = [
  {
    shared: false
    unique: false
    system_name: null
    configuration: null

    expected: [
      configuration/bat/config
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
      configuration/systems/darwin/hosts/benrosen/configuration.nix
      configuration/systems/darwin/hosts/benrosen/home.nix
      configuration/systems/darwin/hosts/work/configuration.nix
      configuration/systems/darwin/hosts/work/git/.gitconfig
      configuration/systems/darwin/hosts/work/home.nix
      configuration/systems/darwin/hosts/work/jj/config.toml
      configuration/systems/darwin/nushell/theme-function.nu
      configuration/systems/darwin/rustup/settings.toml
      configuration/systems/darwin/tinty/fzf.toml
      configuration/systems/nixos/configuration.nix
      configuration/systems/nixos/home.nix
      configuration/systems/nixos/hosts/bumbirich/configuration.nix
      configuration/systems/nixos/hosts/bumbirich/hardware-configuration.nix
      configuration/systems/nixos/hosts/bumbirich/home.nix
      configuration/systems/nixos/hosts/bumbirich/hypr/hyprland.conf
      configuration/systems/nixos/hosts/ruzia/configuration.nix
      configuration/systems/nixos/hosts/ruzia/hardware-configuration.nix
      configuration/systems/nixos/hosts/ruzia/home.nix
      configuration/systems/nixos/hypr/hyprland.conf
      configuration/systems/nixos/hypr/hyprpaper.conf
      configuration/systems/nixos/hypr/wallpaper/hildegard.jpeg
      configuration/systems/nixos/nushell/theme-function.nu
      configuration/systems/nixos/rofi/config.rasi
      configuration/systems/nixos/rustup/settings.toml
      configuration/systems/nixos/swaync/style.css
      configuration/systems/nixos/tinty/fzf.toml
      configuration/systems/nixos/tinty/rofi.toml
      configuration/systems/nixos/tinty/waybar.toml
      configuration/systems/nixos/waybar/colors.css
      configuration/systems/nixos/waybar/config.jsonc
      configuration/systems/nixos/waybar/style.css
      configuration/tealdeer/config.toml
      configuration/tinty/helix.toml
      configuration/tinty/kitty.toml
      configuration/tinty/shell.toml
      configuration/vivid/themes/theme.yml
      configuration/zellij/themes/theme.kdl
    ]
  }

  {
    shared: false
    unique: false
    system_name: darwin
    configuration: darwin

    expected: [
      configuration/bat/config
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
      configuration/systems/darwin/hosts/benrosen/configuration.nix
      configuration/systems/darwin/hosts/benrosen/home.nix
      configuration/systems/darwin/hosts/work/configuration.nix
      configuration/systems/darwin/hosts/work/git/.gitconfig
      configuration/systems/darwin/hosts/work/home.nix
      configuration/systems/darwin/hosts/work/jj/config.toml
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
  }

  {
    shared: false
    unique: false
    system_name: nixos
    configuration: ruzia

    expected: [
      configuration/bat/config
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
      configuration/systems/nixos/configuration.nix
      configuration/systems/nixos/home.nix
      configuration/systems/nixos/hosts/ruzia/configuration.nix
      configuration/systems/nixos/hosts/ruzia/hardware-configuration.nix
      configuration/systems/nixos/hosts/ruzia/home.nix
      configuration/systems/nixos/hypr/hyprland.conf
      configuration/systems/nixos/hypr/hyprpaper.conf
      configuration/systems/nixos/hypr/wallpaper/hildegard.jpeg
      configuration/systems/nixos/nushell/theme-function.nu
      configuration/systems/nixos/rofi/config.rasi
      configuration/systems/nixos/rustup/settings.toml
      configuration/systems/nixos/swaync/style.css
      configuration/systems/nixos/tinty/fzf.toml
      configuration/systems/nixos/tinty/rofi.toml
      configuration/systems/nixos/tinty/waybar.toml
      configuration/systems/nixos/waybar/colors.css
      configuration/systems/nixos/waybar/config.jsonc
      configuration/systems/nixos/waybar/style.css
      configuration/tealdeer/config.toml
      configuration/tinty/helix.toml
      configuration/tinty/kitty.toml
      configuration/tinty/shell.toml
      configuration/vivid/themes/theme.yml
      configuration/zellij/themes/theme.kdl
    ]
  }

  {
    shared: true
    unique: false
    system_name: null
    configuration: null

    expected: [
      configuration/bat/config
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
      configuration/tealdeer/config.toml
      configuration/tinty/helix.toml
      configuration/tinty/kitty.toml
      configuration/tinty/shell.toml
      configuration/vivid/themes/theme.yml
      configuration/zellij/themes/theme.kdl
    ]
  }

  {
    shared: true
    unique: false
    system_name: nixos
    configuration: nixos

    expected: [
      configuration/bat/config
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
      configuration/systems/nixos/configuration.nix
      configuration/systems/nixos/home.nix
      configuration/systems/nixos/hypr/hyprland.conf
      configuration/systems/nixos/hypr/hyprpaper.conf
      configuration/systems/nixos/hypr/wallpaper/hildegard.jpeg
      configuration/systems/nixos/nushell/theme-function.nu
      configuration/systems/nixos/rofi/config.rasi
      configuration/systems/nixos/rustup/settings.toml
      configuration/systems/nixos/swaync/style.css
      configuration/systems/nixos/tinty/fzf.toml
      configuration/systems/nixos/tinty/rofi.toml
      configuration/systems/nixos/tinty/waybar.toml
      configuration/systems/nixos/waybar/colors.css
      configuration/systems/nixos/waybar/config.jsonc
      configuration/systems/nixos/waybar/style.css
      configuration/tealdeer/config.toml
      configuration/tinty/helix.toml
      configuration/tinty/kitty.toml
      configuration/tinty/shell.toml
      configuration/vivid/themes/theme.yml
      configuration/zellij/themes/theme.kdl
    ]
  }

  {
    shared: true
    unique: false
    system_name: darwin
    configuration: benrosen

    expected: [
      configuration/bat/config
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
      configuration/systems/darwin/hosts/benrosen/configuration.nix
      configuration/systems/darwin/hosts/benrosen/home.nix
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
  }

  {
    shared: false
    unique: true
    system_name: null
    configuration: null

    expected: [
      configuration/bat/config
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
      configuration/systems/darwin/hosts/benrosen/configuration.nix
      configuration/systems/darwin/hosts/benrosen/home.nix
      configuration/systems/darwin/hosts/work/configuration.nix
      configuration/systems/darwin/hosts/work/git/.gitconfig
      configuration/systems/darwin/hosts/work/home.nix
      configuration/systems/darwin/hosts/work/jj/config.toml
      configuration/systems/darwin/nushell/theme-function.nu
      configuration/systems/darwin/rustup/settings.toml
      configuration/systems/darwin/tinty/fzf.toml
      configuration/systems/nixos/configuration.nix
      configuration/systems/nixos/home.nix
      configuration/systems/nixos/hosts/bumbirich/configuration.nix
      configuration/systems/nixos/hosts/bumbirich/hardware-configuration.nix
      configuration/systems/nixos/hosts/bumbirich/home.nix
      configuration/systems/nixos/hosts/bumbirich/hypr/hyprland.conf
      configuration/systems/nixos/hosts/ruzia/configuration.nix
      configuration/systems/nixos/hosts/ruzia/hardware-configuration.nix
      configuration/systems/nixos/hosts/ruzia/home.nix
      configuration/systems/nixos/hypr/hyprland.conf
      configuration/systems/nixos/hypr/hyprpaper.conf
      configuration/systems/nixos/hypr/wallpaper/hildegard.jpeg
      configuration/systems/nixos/nushell/theme-function.nu
      configuration/systems/nixos/rofi/config.rasi
      configuration/systems/nixos/rustup/settings.toml
      configuration/systems/nixos/swaync/style.css
      configuration/systems/nixos/tinty/fzf.toml
      configuration/systems/nixos/tinty/rofi.toml
      configuration/systems/nixos/tinty/waybar.toml
      configuration/systems/nixos/waybar/colors.css
      configuration/systems/nixos/waybar/config.jsonc
      configuration/systems/nixos/waybar/style.css
      configuration/tealdeer/config.toml
      configuration/tinty/helix.toml
      configuration/tinty/kitty.toml
      configuration/tinty/shell.toml
      configuration/vivid/themes/theme.yml
      configuration/zellij/themes/theme.kdl
    ]
  }

  {
    shared: false
    unique: true
    system_name: darwin
    configuration: darwin

    expected: [
      configuration/systems/darwin/.hushlogin
      configuration/systems/darwin/configuration.nix
      configuration/systems/darwin/home.nix
      configuration/systems/darwin/hosts/benrosen/configuration.nix
      configuration/systems/darwin/hosts/benrosen/home.nix
      configuration/systems/darwin/hosts/work/configuration.nix
      configuration/systems/darwin/hosts/work/git/.gitconfig
      configuration/systems/darwin/hosts/work/home.nix
      configuration/systems/darwin/hosts/work/jj/config.toml
      configuration/systems/darwin/nushell/theme-function.nu
      configuration/systems/darwin/rustup/settings.toml
      configuration/systems/darwin/tinty/fzf.toml
    ]
  }

  {
    shared: false
    unique: true
    system_name: nixos
    configuration: bumbirich

    expected: [
      configuration/systems/nixos/hosts/bumbirich/configuration.nix
      configuration/systems/nixos/hosts/bumbirich/hardware-configuration.nix
      configuration/systems/nixos/hosts/bumbirich/home.nix
      configuration/systems/nixos/hosts/bumbirich/hypr/hyprland.conf
    ]
  }

  {
    shared: true
    unique: true
    system_name: null
    configuration: null

    expected: [
      configuration/bat/config
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
      configuration/tealdeer/config.toml
      configuration/tinty/helix.toml
      configuration/tinty/kitty.toml
      configuration/tinty/shell.toml
      configuration/vivid/themes/theme.yml
      configuration/zellij/themes/theme.kdl
    ]
  }

  {
    shared: true
    unique: true
    system_name: nixos
    configuration: nixos

    expected: [
      configuration/systems/nixos/configuration.nix
      configuration/systems/nixos/home.nix
      configuration/systems/nixos/hypr/hyprland.conf
      configuration/systems/nixos/hypr/hyprpaper.conf
      configuration/systems/nixos/hypr/wallpaper/hildegard.jpeg
      configuration/systems/nixos/nushell/theme-function.nu
      configuration/systems/nixos/rofi/config.rasi
      configuration/systems/nixos/rustup/settings.toml
      configuration/systems/nixos/swaync/style.css
      configuration/systems/nixos/tinty/fzf.toml
      configuration/systems/nixos/tinty/rofi.toml
      configuration/systems/nixos/tinty/waybar.toml
      configuration/systems/nixos/waybar/colors.css
      configuration/systems/nixos/waybar/config.jsonc
      configuration/systems/nixos/waybar/style.css
    ]
  }

  {
    shared: true
    unique: true
    system_name: darwin
    configuration: work

    expected: [
      configuration/systems/darwin/hosts/work/configuration.nix
      configuration/systems/darwin/hosts/work/git/.gitconfig
      configuration/systems/darwin/hosts/work/home.nix
      configuration/systems/darwin/hosts/work/jj/config.toml
    ]
  }
]

for test in $tests {
  let actual = (
    filter-files
    $files
    $system_names
    $host_names
    $test.shared
    $test.unique
    $test.system_name
    $test.configuration
  )

  assert equal $actual $test.expected
}
