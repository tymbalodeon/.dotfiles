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

  imports = [../home-manager];

  options.home-user = with types; let
    user = import ../home-manager/users/user.nix;
  in {
    username = mkOption {
      default = user.username;
      type = str;
    };
  };
}
