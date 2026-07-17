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
      ./editor
      ./eza
      ./fastfetch
      ./file-manager
      ./fonts
      ./fzf
      ./gemini
      ./gpg
      ./irc
      ./jq
      ./media
      # FIXME
      # ./musescore
      ./networking
      ../nix
      ./nix
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
      ./terminal
      ./version-control
      ./vivid
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
      defaultUser = import ../users;
    in {
      email = mkOption {
        default = builtins.elemAt defaultUser.email.addresses 0;
        type = str;
      };

      githubUsername = mkOption {
        default = defaultUser.githubUsername;
        type = str;
      };

      gitlabUsername = mkOption {
        default = defaultUser.gitlabUsername;
        type = str;
      };

      name = mkOption {
        default = defaultUser.name;
        type = str;
      };

      nbRemotes = mkOption {
        default =
          if builtins.hasAttr "nbRemotes" defaultUser
          then defaultUser.nbRemotes
          else ["git@codeberg.org:${defaultUser.githubUsername}/notes.git"];
        type = listOf str;
      };

      username = mkOption {
        default = defaultUser.username;
        type = str;
      };
    };
  };
}
