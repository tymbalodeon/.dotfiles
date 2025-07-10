use std assert

use ../diff.nu get-diff-files
use ../diff.nu get-files-to-diff
use ../diff.nu list-files
use ../diff.nu sort-delta-files
use ../diff.nu sort-diff-files

let shared_files = [
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

#[before-all]
def get-mock-files [] {
  {
    mocks: (fd --hidden "" (fd mocks) | lines)
  }
}

def get-mock-file [mocks: list<string> filename: string] {
  open (
    $mocks
    | where {
        |file|

        ($file | path basename) == $filename
      }
    | first
  )
  | str trim
}

#[test]
def test-get-diff-files [] {
  let actual_diff_files = (get-diff-files $shared_files $target_files)

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
}

#[test]
def test-get-diff-files-when-in-both [] {
  let actual_diff_files = (get-diff-files $shared_files $target_files home.nix)

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
}

#[test]
def test-get-diff-files-when-in-one [] {
  let actual_diff_files = (
    get-diff-files $shared_files $target_files zellij/themes/theme.kdl
  )

  assert equal $actual_diff_files []
}

let benrosen_files = [
  configuration/systems/darwin/hosts/benrosen/configuration.nix
  configuration/systems/darwin/hosts/benrosen/home.nix
  configuration/systems/darwin/.hushlogin
  configuration/systems/darwin/configuration.nix
  configuration/systems/darwin/home.nix
  configuration/systems/darwin/nushell/theme-function.nu
  configuration/systems/darwin/rustup/settings.toml
  configuration/systems/darwin/tinty/fzf.toml
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
  configuration/tealdeer/config.toml
  configuration/tinty/helix.toml
  configuration/tinty/kitty.toml
  configuration/tinty/shell.toml
  configuration/vivid/themes/theme.yml
  configuration/zellij/themes/theme.kdl
]

#[test]
def test-get-files-to-diff-shared-benrosen [] {
  let actual_files = (
    get-files-to-diff
      shared
      benrosen
      $shared_files
      $benrosen_files
  )

  assert equal $actual_files $shared_files
}

#[test]
def test-get-files-to-diff-benrosen-shared [] {
  let actual_files = (
    get-files-to-diff
      benrosen
      shared
      $benrosen_files
      $shared_files
  )

  let expected_files = [
    configuration/systems/darwin/hosts/benrosen/configuration.nix
    configuration/systems/darwin/hosts/benrosen/home.nix
  ]

  assert equal $actual_files $expected_files
}

#[test]
def test-get-files-to-diff-darwin-nixos [] {
    let all_self_files = [
    configuration/systems/darwin/.hushlogin
    configuration/systems/darwin/configuration.nix
    configuration/systems/darwin/home.nix
    configuration/systems/darwin/nushell/theme-function.nu
    configuration/systems/darwin/rustup/settings.toml
    configuration/systems/darwin/tinty/fzf.toml
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
    configuration/tealdeer/config.toml
    configuration/tinty/helix.toml
    configuration/tinty/kitty.toml
    configuration/tinty/shell.toml
    configuration/vivid/themes/theme.yml
    configuration/zellij/themes/theme.kdl
  ]

  let all_other_files = [
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

  let actual_files = (
    get-files-to-diff
      darwin
      nixos
      $all_self_files
      $all_other_files
  )

  assert equal $actual_files $all_self_files
}

#[test]
def test-list-files [] {
  let expected = (get-mock-file $in.mocks diff--list-files.txt)
  let actual = (list-files $shared_files $target_files false)

  assert equal $actual $expected
}

#[test]
def test-list-files-sort-by-target [] {
  let expected = (
    get-mock-file $in.mocks diff--list-files--sort-by-target.txt
  )

  let actual = (list-files $shared_files $target_files true)

  assert equal $actual $expected
}

#[test]
def test-list-files-file [] {
  let expected = (get-mock-file $in.mocks diff--list-files--file.txt)

  let actual = (
    list-files $shared_files $target_files false configuration.nix
  )

  assert equal $actual $expected
}

#[test]
def test-list-files-file-sort-by-target [] {
  let expected = (
    get-mock-file $in.mocks diff--list-files--file--sort-by-target.txt
  )

  let actual = (list-files $shared_files $target_files true home.nix)

  assert equal $actual $expected
}

let a = "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Δ configuration/systems/darwin/configuration.nix ⟶   configuration/systems/darwin/hosts/benrosen/configuration.nix
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

───────────────────────────────────────────────────────────────────┐
• configuration/systems/darwin/hosts/benrosen/configuration.nix:1: │
───────────────────────────────────────────────────────────────────┘
│  1 │{inputs, ...}: {                                                                     │    │
│  2 │  home-manager = {                                                                   │    │
│  3 │    extraSpecialArgs = {inherit inputs;};                                            │    │
│  4 │    users.benrosen = import ./home.nix;                                              │    │
│  5 │  };                                                                                 │    │
│  6 │                                                                                     │    │
│  7 │  imports = [inputs.home-manager.darwinModules.home-manager];                        │    │
│  8 │                                                                                     │    │
│  9 │  nix.enable = false;                                                                │    │
│ 10 │  # nix.extraOptions = ''                                                            │    │
│ 11 │  #   bash-prompt-prefix = (nix:$name)\\040                                           │    │
│ 12 │  #   experimental-features = flakes nix-command                                     │    │
│ 13 │  #   extra-nix-path = nixpkgs=flake:nixpkgs                                         │    │
│ 14 │  #   upgrade-nix-store-path-url = https://install.determinate.systems/nix-upgrade/s↴│    │
│    │                                                                     …table/universal│    │
│ 15 │  # '';                                                                              │    │
│ 16 │                                                                                     │    │
│ 17 │  security.sudo.extraConfig = ''                                                     │    │
│ 18 │    Defaults env_keep += \"TERM TERMINFO\"                                             │    │
│ 19 │  '';                                                                                │    │
│ 20 │                                                                                     │    │
│ 21 │  system = {                                                                         │    │
│ 22 │    activationScripts.postUserActivation.text = ''                                   │    │
│ 23 │      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/act↴│    │
│    │                                                                    …ivateSettings -u│    │
│ 24 │    '';                                                                              │    │
│ 25 │                                                                                     │    │
│ 26 │    defaults = {                                                                     │    │
│ 27 │      controlcenter = {                                                              │    │
│ 28 │        Bluetooth = true;                                                            │    │
│ 29 │        FocusModes = true;                                                           │    │
│ 30 │        NowPlaying = true;                                                           │    │
│ 31 │        Sound = true;                                                                │    │
│ 32 │      };                                                                             │    │
│ 33 │                                                                                     │    │
│ 34 │      dock = {                                                                       │    │
│ 35 │        autohide = true;                                                             │    │
│ 36 │        mineffect = \"scale\";                                                         │    │
│ 37 │      };                                                                             │    │
│ 38 │                                                                                     │    │
│ 39 │      menuExtraClock.IsAnalog = false;                                               │    │
│ 40 │      NSGlobalDomain._HIHideMenuBar = true;                                          │    │
│ 41 │      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;                        │    │
│ 42 │    };                                                                               │    │
│ 43 │                                                                                     │    │
│ 44 │    keyboard = {                                                                     │    │
│ 45 │      enableKeyMapping = true;                                                       │    │
│ 46 │      remapCapsLockToEscape = true;                                                  │    │
│ 47 │    };                                                                               │    │
│ 48 │                                                                                     │    │
│ 49 │    stateVersion = 6;                                                                │    │
│ 50 │  };                                                                                 │    │
│ 51 │                                                                                     │    │
│    │                                                                                     │  1 │{...}: {
│ 52 │  users.users.benrosen.home = \"/Users/benrosen\";                                     │  2 │  home-manager.users.benrosen = import ./home.nix;
│    │                                                                                     │  3 │  imports = [../../configuration.nix];
│ 53 │}                                                                                    │  4 │}"


let b = "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Δ configuration/home.nix ⟶   configuration/systems/darwin/hosts/benrosen/home.nix
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

──────────────────────────────────────────────────────────┐
• configuration/systems/darwin/hosts/benrosen/home.nix:1: │
──────────────────────────────────────────────────────────┘
│  1 │{                                                                                    │    │
│  2 │  inputs,                                                                            │    │
│  3 │  pkgs,                                                                              │    │
│  4 │  ...                                                                                │    │
│  5 │}: {                                                                                 │    │
│  6 │  fonts.fontconfig.enable = true;                                                    │    │
│  7 │                                                                                     │    │
│  8 │  home = {                                                                           │    │
│  9 │    file = {                                                                         │    │
│ 10 │      \".config/bat/config\".source = ./bat/config;                                    │    │
│ 11 │                                                                                     │    │
│ 12 │      \".config/bat/syntaxes/nushell.sublime-syntax\".source =                         │    │
│ 13 │        inputs.nushell-syntax + \"/nushell.sublime-syntax\";                           │    │
│ 14 │                                                                                     │    │
│ 15 │      \".config/helix/config.toml\".source = ./helix/config.toml;                      │    │
│ 16 │      \".config/helix/languages.toml\".source = ./helix/languages.toml;                │    │
│ 17 │      \".config/helix/themes/theme.toml\".source = ./helix/themes/theme.toml;          │    │
│ 18 │      \".config/kitty/theme.conf\".source = ./kitty/theme.conf;                        │    │
│ 19 │      \".config/tinty/helix.toml\".source = ./tinty/helix.toml;                        │    │
│ 20 │      \".config/tinty/kitty.toml\".source = ./tinty/kitty.toml;                        │    │
│ 21 │      \".config/tinty/shell.toml\".source = ./tinty/shell.toml;                        │    │
│ 22 │      \".config/vivid/themes/theme.yml\".source = ./vivid/themes/theme.yml;            │    │
│ 23 │      \".config/zellij/themes/theme.kdl\".source = ./zellij/themes/theme.kdl;          │    │
│ 24 │    };                                                                               │    │
│ 25 │                                                                                     │    │
│ 26 │    packages = with pkgs; [                                                          │    │
│ 27 │      bat                                                                            │    │
│ 28 │      bat-extras.batman                                                              │    │
│ 29 │      bottom                                                                         │    │
│ 30 │      chuck                                                                          │    │
│ 31 │      clang                                                                          │    │
│ 32 │      clang-tools                                                                    │    │
│ 33 │      coreutils                                                                      │    │
│ 34 │      dejavu_fonts                                                                   │    │
│ 35 │      delta                                                                          │    │
│ 36 │      dogdns                                                                         │    │
│ 37 │      duf                                                                            │    │
│ 38 │      dust                                                                           │    │
│ 39 │      eza                                                                            │    │
│ 40 │      fastfetch                                                                      │    │
│ 41 │      fd                                                                             │    │
│ 42 │      fh                                                                             │    │
│ 43 │      fira-code                                                                      │    │
│ 44 │      font-awesome                                                                   │    │
│ 45 │      fzf                                                                            │    │
│ 46 │      gh                                                                             │    │
│ 47 │      ghc                                                                            │    │
│ 48 │      git                                                                            │    │
│ 49 │      gitui                                                                          │    │
│ 50 │      glab                                                                           │    │
│ 51 │      glow                                                                           │    │
│ 52 │      gnum4                                                                          │    │
│ 53 │      google-java-format                                                             │    │
│ 54 │      gyre-fonts                                                                     │    │
│ 55 │      helix                                                                          │    │
│ 56 │      hexyl                                                                          │    │
│ 57 │      hyperfine                                                                      │    │
│ 58 │      ibm-plex                                                                       │    │
│ 59 │      inconsolata                                                                    │    │
│ 60 │      jdt-language-server                                                            │    │
│ 61 │      jq                                                                             │    │
│ 62 │      just                                                                           │    │
│ 63 │      liberation_ttf                                                                 │    │
│ 64 │      lilypond-unstable-with-fonts                                                   │    │
│ 65 │      lldb                                                                           │    │
│ 66 │      marksman                                                                       │    │
│ 67 │      nb                                                                             │    │
│ 68 │      nerd-fonts.jetbrains-mono                                                      │    │
│ 69 │      nix-search-cli                                                                 │    │
│ 70 │      nodePackages.bash-language-server                                              │    │
│ 71 │      nodePackages.typescript-language-server                                        │    │
│ 72 │      noto-fonts                                                                     │    │
│ 73 │      openjdk                                                                        │    │
│ 74 │      ov                                                                             │    │
│ 75 │      pandoc                                                                         │    │
│ 76 │      pipx                                                                           │    │
│ 77 │      pup                                                                            │    │
│ 78 │      pyright                                                                        │    │
│ 79 │      python313                                                                      │    │
│ 80 │      rainfrog                                                                       │    │
│ 81 │      rakudo                                                                         │    │
│ 82 │      rclone                                                                         │    │
│ 83 │      repgrep                                                                        │    │
│ 84 │      ripgrep                                                                        │    │
│ 85 │      ruff-lsp                                                                       │    │
│ 86 │      rustup                                                                         │    │
│ 87 │      sd                                                                             │    │
│ 88 │      shfmt                                                                          │    │
│ 89 │      tealdeer                                                                       │    │
│ 90 │      tinty                                                                          │    │
│ 91 │      tinymist                                                                       │    │
│ 92 │      typst                                                                          │    │
│ 93 │      typstyle                                                                       │    │
│ 94 │      ubuntu_font_family                                                             │    │
│ 95 │      unison-ucm                                                                     │    │
│ 96 │      vivid                                                                          │    │
│ 97 │      w3m                                                                            │    │
│ 98 │      xh                                                                             │    │
│ 99 │      yazi                                                                           │    │
│ 100│      yq-go                                                                          │    │
│ 101│      zathura                                                                        │    │
│ 102│      zellij                                                                         │    │
│ 103│      zola                                                                           │    │
│ 104│      zoxide                                                                         │    │
│ 105│    ];                                                                               │    │
│ 106│                                                                                     │    │
│ 107│    sessionVariables = {EDITOR = \"hx\";};                                             │    │
│ 108│    stateVersion = \"23.11\";                                                          │    │
│ 109│    username = \"benrosen\";                                                           │    │
│    │                                                                                     │  1 │{...}: {
│    │                                                                                     │  2 │  home.file = {
│    │                                                                                     │  3 │    \".gitconfig\".source = ../../../../git/.gitconfig;
│    │                                                                                     │  4 │    \"Library/Application Support/jj/config.toml\".source = ../../../../jj/config.toml;
│ 110│  };                                                                                 │  5 │  };
│ 111│                                                                                     │  6 │
│ 112│  news.display = \"silent\";                                                           │    │
│ 113│  nixpkgs.config.allowUnfree = true;                                                 │    │
│ 114│                                                                                     │    │
│ 115│  programs = {                                                                       │    │
│ 116│    direnv = {                                                                       │    │
│ 117│      enable = true;                                                                 │    │
│ 118│      enableNushellIntegration = true;                                               │    │
│ 119│      nix-direnv.enable = true;                                                      │    │
│ 120│    };                                                                               │    │
│ 121│                                                                                     │    │
│ 122│    git = {                                                                          │    │
│ 123│      enable = true;                                                                 │    │
│ 124│      userName = \"Ben Rosen\";                                                        │    │
│ 125│      userEmail = \"benjamin.j.rosen@gmail.com\";                                      │    │
│ 126│    };                                                                               │    │
│ 127│                                                                                     │    │
│ 128│    helix = {                                                                        │    │
│ 129│      enable = true;                                                                 │    │
│ 130│      defaultEditor = true;                                                          │    │
│ 131│    };                                                                               │    │
│ 132│                                                                                     │    │
│ 133│    home-manager.enable = true;                                                      │    │
│ 134│                                                                                     │    │
│ 135│    kitty = {                                                                        │    │
│ 136│      enable = true;                                                                 │    │
│ 137│                                                                                     │    │
│ 138│      extraConfig = ''                                                               │    │
│ 139│        map kitty_mod+enter launch --cwd=current --type=window                       │    │
│ 140│        font_features FiraCodeRoman-Regular +zero +onum +cv30 +ss09 +cv25 +cv26 +cv3↴│    │
│    │                                                                             …2 +ss07│    │
│ 141│        font_features FiraCodeRoman-SemiBold +zero +onum +cv30 +ss09 +cv25 +cv26 +cv↴│    │
│    │                                                                            …32 +ss07│    │
│ 142│      '';                                                                            │    │
│ 143│                                                                                     │    │
│ 144│      settings = {                                                                   │    │
│ 145│        confirm_os_window_close = 0;                                                 │    │
│ 146│        enable_audio_bell = \"no\";                                                    │    │
│ 147│        enabled_layouts = \"grid, stack, vertical, horizontal, tall\";                 │    │
│ 148│        font_family = \"Fira Code\";                                                   │    │
│ 149│        inactive_text_alpha = \"0.5\";                                                 │    │
│ 150│        include = \"theme.conf\";                                                      │    │
│ 151│        tab_bar_edge = \"top\";                                                        │    │
│ 152│        tab_bar_style = \"powerline\";                                                 │    │
│ 153│        tab_powerline_style = \"slanted\";                                             │    │
│ 154│      };                                                                             │    │
│ 155│    };                                                                               │    │
│ 156│                                                                                     │    │
│ 157│    nushell = {                                                                      │    │
│ 158│      enable = true;                                                                 │    │
│ 159│      configFile.source = ./nushell/config.nu;                                       │    │
│ 160│      envFile.source = ./nushell/env.nu;                                             │    │
│ 161│    };                                                                               │    │
│ 162│  };                                                                                 │    │
│    │                                                                                     │  7 │  imports = [../../home.nix];
│ 163│}                                                                                    │  8 │}"

#[test]
def test-sort-delta-files [] {
  assert equal (sort-delta-files $a $b false) false
}

#[test]
def test-sort-delta-files-by-target [] {
  assert equal (sort-delta-files $a $b true) true
}

#[test]
def test-sort-delta-files-flipped [] {
  assert equal (sort-delta-files $b $a false) true
}

#[test]
def test-sort-delta-files-by-target-flipped [] {
  assert equal (sort-delta-files $b $a true) false
}

let a = "configuration/systems/darwin/configuration.nix -> configuration/systems/darwin/hosts/benrosen/configuration.nix"
let b = "configuration/home.nix -> configuration/systems/darwin/hosts/benrosen/home.nix"

#[test]
def test-sort-diff-files [] {
  assert equal (sort-diff-files $a $b false) false
}

#[test]
def test-sort-diff-files-by-target [] {
  assert equal (sort-diff-files $a $b true) true
}

#[test]
def test-sort-diff-files-flipped [] {
  assert equal (sort-diff-files $b $a false) true
}

#[test]
def test-sort-diff-files-by-target-flipped [] {
  assert equal (sort-diff-files $b $a true) false
}
