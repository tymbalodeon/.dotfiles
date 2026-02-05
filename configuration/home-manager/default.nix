{
  config,
  hostType,
  lib,
  pkgs,
  ...
}: {
  config = {
    home = {
      packages = with pkgs; [
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
      username = config.user.username;
    };

    news.display = "silent";

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nixpkgs.config.allowUnfree = true;
    programs.home-manager.enable = true;
  };

  imports =
    [
      ./bat
      ./bottom
      ./brave
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
      ./nb
      ./ripgrep
      ./shell
      ./taskwarrior
      ./tealdeer
      ./yazi
      ./zathura
      ./zellij
      ./zk
      ./zoxide
      ./zen-browser
    ]
    ++ (
      if hostType == "darwin"
      then [./darwin]
      else if hostType == "home-manager"
      then [./home-manager]
      else if hostType == "nixos"
      then [./nixos]
      else []
    );

  options = let
    inherit (lib) mkOption types;
  in {
    laptop = mkOption {
      default = false;
      type = types.bool;
    };

    user = let
      str = types.str;
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

      nbRemote = mkOption {
        default =
          if builtins.hasAttr "nbRemote" user
          then user.nbRemote
          else "git@github.com:${user.githubUsername}/notes.git";

        type = str;
      };

      username = mkOption {
        default = user.username;
        type = str;
      };
    };
  };
}
