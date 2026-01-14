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
      username = config.username;
    };

    news.display = "silent";
    programs.home-manager.enable = true;
  };

  imports =
    [
      ./bat
      ./bottom
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
      ./mpv
      ./music-player
      ./nb
      ./ripgrep
      ./shell
      ./taskwarrior
      ./tealdeer
      ./yazi
      ./zathura
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
    );

  options.username = let
    user = import ../users;
  in
    with lib;
      mkOption {
        default = user.username;
        type = types.str;
      };
}
