{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.home-user;
  in {
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
      username = cfg.username;
    };

    news.display = "silent";
    programs.home-manager.enable = true;
  };

  imports = [
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
  ];

  options.home-user = with types; let
    user = import ./users/user.nix;
  in {
    username = mkOption {
      default = user.username;
      type = str;
    };
  };
}
