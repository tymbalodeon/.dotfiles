{
  channel,
  config,
  hostType,
  lib,
  pkgs,
  ...
}: {
  config = {
    gtk.gtk4.theme = null;

    home = {
      packages = with pkgs; [
        devenv
        doggo
        dua
        dust
        fd
        glow
        hexyl
        hyperfine
        just
        mprocs
        nix-search-cli
        nurl
        ov
        pipx
        presenterm
        pup
        python313
        rainfrog
        repgrep
        sd
        tinty
        uutils-coreutils-noprefix
        wiki-tui
        xh
        yq-go
      ];

      stateVersion = "23.11";
      inherit (config.user) username;
    };

    news.display = "silent";
    nixpkgs.config.allowUnfree = true;
    programs.home-manager.enable = true;
  };

  imports =
    [
      ./bat
      ./bottom
      ./comma
      ./direnv
      ./eza
      ./fastfetch
      ./fonts
      ./fzf
      ./git
      ./gpg
      ./helix
      ./jq
      ./jujutsu
      ./kitty
      ./musescore
      ./nh
      ../nix
      ./note
      ./nushell
      ./pdf
      ./ripgrep
      ./src
      ./shell
      ./tealdeer
      ./vivid
      ./yazi
      ./zellij
      ./zoxide
    ]
    ++ (
      if hostType == "darwin"
      then [./darwin]
      else if hostType == "home-manager"
      then [./home-manager]
      else if hostType == "nixos"
      then [./nixos]
      else []
    )
    ++ (
      if channel == "unstable"
      then [./taskwarrior]
      else []
    );

  options = let
    inherit (lib) mkOption types;
    inherit (types) bool listOf str;
  in {
    laptop = mkOption {
      default = false;
      type = bool;
    };

    user = let
      user = import ../users;
    in {
      email = mkOption {
        default = user.email;
        type = str;
      };

      githubUsername = mkOption {
        default = user.githubUsername;
        type = str;
      };

      gitlabUsername = mkOption {
        default = user.gitlabUsername;
        type = str;
      };

      name = mkOption {
        default = user.name;
        type = str;
      };

      nbRemotes = mkOption {
        default =
          if builtins.hasAttr "nbRemotes" user
          then user.nbRemotes
          else ["git@github.com:${user.githubUsername}/notes.git"];

        type = listOf str;
      };

      username = mkOption {
        default = user.username;
        type = str;
      };
    };
  };
}
