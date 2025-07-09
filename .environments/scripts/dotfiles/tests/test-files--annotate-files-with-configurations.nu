use std assert

use ../files.nu annotate-files-with-configurations

let all_configurations = [
  benrosen
  bumbirich
  darwin
  nixos
  ruzia
  work
]

let colors = [
  [configuration name];
  [benrosen green]
  [bumbirich red]
  [darwin blue]
  [nixos yellow]
  [ruzia magenta]
  [work cyan]
]

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

let darwin_files = [
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

let benrosen_files = [
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

let unique_darwin_files = [
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

let unique_benrosen_files = [
  configuration/systems/darwin/hosts/benrosen/configuration.nix
  configuration/systems/darwin/hosts/benrosen/home.nix
]

let annotated_files = [
  "configuration/bat/config"
  "configuration/flake.nix"
  "configuration/git/.gitconfig"
  "configuration/helix/config.toml"
  "configuration/helix/languages.toml"
  "configuration/helix/themes/theme.toml"
  "configuration/home.nix"
  "configuration/jj/config.toml"
  "configuration/kitty/theme.conf"
  "configuration/nushell/aliases.nu"
  "configuration/nushell/cloud.nu"
  "configuration/nushell/colors.nu"
  "configuration/nushell/config.nu"
  "configuration/nushell/env.nu"
  "configuration/nushell/f.nu"
  "configuration/nushell/prompt.nu"
  "configuration/nushell/src.nu"
  "configuration/nushell/theme.nu"
  "configuration/nushell/themes.toml"
  "configuration/systems/darwin/.hushlogin darwin"
  "configuration/systems/darwin/configuration.nix darwin"
  "configuration/systems/darwin/home.nix darwin"
  "configuration/systems/darwin/hosts/benrosen/configuration.nix darwin benrosen"
  "configuration/systems/darwin/hosts/benrosen/home.nix darwin benrosen"
  "configuration/systems/darwin/hosts/work/configuration.nix darwin work"
  "configuration/systems/darwin/hosts/work/git/.gitconfig darwin work"
  "configuration/systems/darwin/hosts/work/home.nix darwin work"
  "configuration/systems/darwin/hosts/work/jj/config.toml darwin work"
  "configuration/systems/darwin/nushell/theme-function.nu darwin"
  "configuration/systems/darwin/rustup/settings.toml darwin"
  "configuration/systems/darwin/tinty/fzf.toml darwin"
  "configuration/systems/nixos/configuration.nix nixos"
  "configuration/systems/nixos/home.nix nixos"
  "configuration/systems/nixos/hosts/bumbirich/configuration.nix nixos bumbirich"
  "configuration/systems/nixos/hosts/bumbirich/hardware-configuration.nix nixos bumbirich"
  "configuration/systems/nixos/hosts/bumbirich/home.nix nixos bumbirich"
  "configuration/systems/nixos/hosts/bumbirich/hypr/hyprland.conf nixos bumbirich"
  "configuration/systems/nixos/hosts/ruzia/configuration.nix nixos ruzia"
  "configuration/systems/nixos/hosts/ruzia/hardware-configuration.nix nixos ruzia"
  "configuration/systems/nixos/hosts/ruzia/home.nix nixos ruzia"
  "configuration/systems/nixos/hypr/hyprland.conf nixos"
  "configuration/systems/nixos/hypr/hyprpaper.conf nixos"
  "configuration/systems/nixos/hypr/wallpaper/hildegard.jpeg nixos"
  "configuration/systems/nixos/nushell/theme-function.nu nixos"
  "configuration/systems/nixos/rofi/config.rasi nixos"
  "configuration/systems/nixos/rustup/settings.toml nixos"
  "configuration/systems/nixos/swaync/style.css nixos"
  "configuration/systems/nixos/tinty/fzf.toml nixos"
  "configuration/systems/nixos/tinty/rofi.toml nixos"
  "configuration/systems/nixos/tinty/waybar.toml nixos"
  "configuration/systems/nixos/waybar/colors.css nixos"
  "configuration/systems/nixos/waybar/config.jsonc nixos"
  "configuration/systems/nixos/waybar/style.css nixos"
  "configuration/tealdeer/config.toml"
  "configuration/tinty/helix.toml"
  "configuration/tinty/kitty.toml"
  "configuration/tinty/shell.toml"
  "configuration/vivid/themes/theme.yml"
  "configuration/zellij/themes/theme.kdl"
]

  let annotated_no_full_path_files = [
  "bat/config"
  "flake.nix"
  "git/.gitconfig"
  "helix/config.toml"
  "helix/languages.toml"
  "helix/themes/theme.toml"
  "home.nix"
  "jj/config.toml"
  "kitty/theme.conf"
  "nushell/aliases.nu"
  "nushell/cloud.nu"
  "nushell/colors.nu"
  "nushell/config.nu"
  "nushell/env.nu"
  "nushell/f.nu"
  "nushell/prompt.nu"
  "nushell/src.nu"
  "nushell/theme.nu"
  "nushell/themes.toml"
  ".hushlogin darwin"
  "configuration.nix darwin"
  "home.nix darwin"
  "configuration.nix darwin benrosen"
  "home.nix darwin benrosen"
  "configuration.nix darwin work"
  "git/.gitconfig darwin work"
  "home.nix darwin work"
  "jj/config.toml darwin work"
  "nushell/theme-function.nu darwin"
  "rustup/settings.toml darwin"
  "tinty/fzf.toml darwin"
  "configuration.nix nixos"
  "home.nix nixos"
  "configuration.nix nixos bumbirich"
  "hardware-configuration.nix nixos bumbirich"
  "home.nix nixos bumbirich"
  "hypr/hyprland.conf nixos bumbirich"
  "configuration.nix nixos ruzia"
  "hardware-configuration.nix nixos ruzia"
  "home.nix nixos ruzia"
  "hypr/hyprland.conf nixos"
  "hypr/hyprpaper.conf nixos"
  "hypr/wallpaper/hildegard.jpeg nixos"
  "nushell/theme-function.nu nixos"
  "rofi/config.rasi nixos"
  "rustup/settings.toml nixos"
  "swaync/style.css nixos"
  "tinty/fzf.toml nixos"
  "tinty/rofi.toml nixos"
  "tinty/waybar.toml nixos"
  "waybar/colors.css nixos"
  "waybar/config.jsonc nixos"
  "waybar/style.css nixos"
  "tealdeer/config.toml"
  "tinty/helix.toml"
  "tinty/kitty.toml"
  "tinty/shell.toml"
  "vivid/themes/theme.yml"
  "zellij/themes/theme.kdl"
]

let annotated_darwin_files = [
  "configuration/bat/config"
  "configuration/flake.nix"
  "configuration/git/.gitconfig"
  "configuration/helix/config.toml"
  "configuration/helix/languages.toml"
  "configuration/helix/themes/theme.toml"
  "configuration/home.nix"
  "configuration/jj/config.toml"
  "configuration/kitty/theme.conf"
  "configuration/nushell/aliases.nu"
  "configuration/nushell/cloud.nu"
  "configuration/nushell/colors.nu"
  "configuration/nushell/config.nu"
  "configuration/nushell/env.nu"
  "configuration/nushell/f.nu"
  "configuration/nushell/prompt.nu"
  "configuration/nushell/src.nu"
  "configuration/nushell/theme.nu"
  "configuration/nushell/themes.toml"
  "configuration/systems/darwin/.hushlogin darwin"
  "configuration/systems/darwin/configuration.nix darwin"
  "configuration/systems/darwin/home.nix darwin"
  "configuration/systems/darwin/hosts/benrosen/configuration.nix darwin benrosen"
  "configuration/systems/darwin/hosts/benrosen/home.nix darwin benrosen"
  "configuration/systems/darwin/hosts/work/configuration.nix darwin work"
  "configuration/systems/darwin/hosts/work/git/.gitconfig darwin work"
  "configuration/systems/darwin/hosts/work/home.nix darwin work"
  "configuration/systems/darwin/hosts/work/jj/config.toml darwin work"
  "configuration/systems/darwin/nushell/theme-function.nu darwin"
  "configuration/systems/darwin/rustup/settings.toml darwin"
  "configuration/systems/darwin/tinty/fzf.toml darwin"
  "configuration/tealdeer/config.toml"
  "configuration/tinty/helix.toml"
  "configuration/tinty/kitty.toml"
  "configuration/tinty/shell.toml"
  "configuration/vivid/themes/theme.yml"
  "configuration/zellij/themes/theme.kdl"
]

let annotated_benrosen_files = [
  "configuration/bat/config"
  "configuration/flake.nix"
  "configuration/git/.gitconfig"
  "configuration/helix/config.toml"
  "configuration/helix/languages.toml"
  "configuration/helix/themes/theme.toml"
  "configuration/home.nix"
  "configuration/jj/config.toml"
  "configuration/kitty/theme.conf"
  "configuration/nushell/aliases.nu"
  "configuration/nushell/cloud.nu"
  "configuration/nushell/colors.nu"
  "configuration/nushell/config.nu"
  "configuration/nushell/env.nu"
  "configuration/nushell/f.nu"
  "configuration/nushell/prompt.nu"
  "configuration/nushell/src.nu"
  "configuration/nushell/theme.nu"
  "configuration/nushell/themes.toml"
  "configuration/systems/darwin/.hushlogin darwin"
  "configuration/systems/darwin/configuration.nix darwin"
  "configuration/systems/darwin/home.nix darwin"
  "configuration/systems/darwin/hosts/benrosen/configuration.nix darwin benrosen"
  "configuration/systems/darwin/hosts/benrosen/home.nix darwin benrosen"
  "configuration/systems/darwin/nushell/theme-function.nu darwin"
  "configuration/systems/darwin/rustup/settings.toml darwin"
  "configuration/systems/darwin/tinty/fzf.toml darwin"
  "configuration/tealdeer/config.toml"
  "configuration/tinty/helix.toml"
  "configuration/tinty/kitty.toml"
  "configuration/tinty/shell.toml"
  "configuration/vivid/themes/theme.yml"
  "configuration/zellij/themes/theme.kdl"
]

let annotated_unique_darwin_files = [
  configuration/systems/darwin/.hushlogin
  configuration/systems/darwin/configuration.nix
  configuration/systems/darwin/home.nix
  "configuration/systems/darwin/hosts/benrosen/configuration.nix benrosen"
  "configuration/systems/darwin/hosts/benrosen/home.nix benrosen"
  "configuration/systems/darwin/hosts/work/configuration.nix work"
  "configuration/systems/darwin/hosts/work/git/.gitconfig work"
  "configuration/systems/darwin/hosts/work/home.nix work"
  "configuration/systems/darwin/hosts/work/jj/config.toml work"
  configuration/systems/darwin/nushell/theme-function.nu
  configuration/systems/darwin/rustup/settings.toml
  configuration/systems/darwin/tinty/fzf.toml
]

let annotated_unique_benrosen_files = [
  configuration/systems/darwin/hosts/benrosen/configuration.nix
  configuration/systems/darwin/hosts/benrosen/home.nix
]

let tests = [
  {
    files: $files
    group_by_file: false
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: false
    no_labels: false
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $annotated_files
  }

  {
    files: $files
    group_by_file: true
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: false
    no_labels: false
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $annotated_files
  }

  {
    files: $files
    group_by_file: false
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: true
    no_labels: false
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $annotated_no_full_path_files
  }

  {
    files: $files
    group_by_file: true
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: true
    no_labels: false
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $annotated_no_full_path_files
  }

  {
    files: $files
    group_by_file: false
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: false
    no_labels: true
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $files
  }

  {
    files: $files
    group_by_file: true
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: false
    no_labels: true
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $files
  }

  {
    files: $files
    group_by_file: false
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: true
    no_labels: true
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $files
  }

  {
    files: $darwin_files
    group_by_file: false
    is_host_configuration: false
    is_system_configuration: true
    no_full_path: false
    no_labels: false
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $annotated_darwin_files
  }

  {
    files: $benrosen_files
    group_by_file: false
    is_host_configuration: true
    is_system_configuration: false
    no_full_path: false
    no_labels: false
    use_colors: false
    unique: false
    unique_filenames: false
    configuration: null
    expected: $annotated_benrosen_files
  }

  {
    files: $unique_darwin_files
    group_by_file: false
    is_host_configuration: false
    is_system_configuration: true
    no_full_path: false
    no_labels: false
    use_colors: false
    unique: true
    unique_filenames: false
    configuration: null
    expected: $annotated_unique_darwin_files
  }

  {
    files: $unique_benrosen_files
    group_by_file: false
    is_host_configuration: true
    is_system_configuration: false
    no_full_path: false
    no_labels: false
    use_colors: false
    unique: true
    unique_filenames: false
    configuration: null
    expected: $annotated_unique_benrosen_files
  }

  {
    files: $files
    group_by_file: true
    is_host_configuration: false
    is_system_configuration: false
    no_full_path: false
    no_labels: false
    use_colors: true
    unique: false
    unique_filenames: false
    configuration: null

    expected: (
      open (
        $env.FILE_PWD
        | path join mocks/files--annotate-files-with-configurations--group-by-file.nu
      )
      | from nuon
    )
  }
]

for test in $tests {
  let actual = (
    annotate-files-with-configurations
      $test.files
      $colors
      $test.group_by_file
      $test.is_host_configuration
      $test.is_system_configuration
      $test.no_full_path
      $test.no_labels
      $test.use_colors
      $test.unique
      $test.unique_filenames
      $test.configuration
  )

  assert equal $actual $test.expected
}
