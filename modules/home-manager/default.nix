{
  config,
  hostType,
  lib,
  pkgs,
  ...
}: {
  config = {
    home = {
      inherit (config.user) username;

      packages = with pkgs; [
        devenv
        doggo
        dua
        dust
        dysk
        fd
        glow
        harper
        hexyl
        hyperfine
        just
        mprocs
        nix-search-cli
        nix-tree
        nurl
        ov
        poop
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
    };

    news.display = "silent";

    nixpkgs = {
      config.allowUnfree = true;
      overlays = import ../fonts/overlays.nix;
    };

    programs.home-manager.enable = true;

    xdg.configFile."nixpkgs/config.nix" = {
      force = true;

      text = ''
        {allowUnfree = true;}
      '';
    };
  };

  imports =
    [
      ./bat
      ./bottom
      ./broot
      ./browsh
      ./comma
      ./direnv
      ./eza
      ./fastfetch
      ./fonts
      ./fzf
      ./gemini
      ./git
      ./gpg
      ./helix
      ./irc
      ./jq
      ./jujutsu
      ./kitty
      ./mpv
      ./musescore
      ./networking
      ./nh
      ../nix
      ./note
      ./passwords
      ./pdf
      ./ripgrep
      ./rss
      ./secrets
      ./shell
      ./shell
      ./src
      ./task
      ./tealdeer
      ./vivid
      ./yazi
      ./zellij
      ./zoxide
    ]
    ++ (
      if hostType == "home-manager"
      then [./home-manager]
      else if hostType == "nixos"
      then [./nixos]
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
          else ["git@codeberg.org:${user.githubUsername}/notes.git"];
        type = listOf str;
      };

      username = mkOption {
        default = user.username;
        type = str;
      };
    };
  };
}
