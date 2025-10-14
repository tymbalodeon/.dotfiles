{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.home-user;
  in {
    home = {
      packages = with pkgs;
        [
          dogdns
          dua
          dust
          dysk
          fd
          glow
          hexyl
          hyperfine
          just
          mprocs
          ov
          pipx
          presenterm
          pup
          python313
          rainfrog
          repgrep
          sd
          uutils-coreutils-noprefix
          wiki-tui
          xh
          yq-go
        ]
        ++ (
          if stdenv.isLinux
          then [nix-search-cli]
          else [inputs.nixpkgs-nix-search-cli.legacyPackages.x86_64-darwin.nix-search-cli]
        );

      stateVersion = "23.11";
      username = cfg.username;
    };

    news.display = "silent";
    programs.home-manager.enable = true;
  };

  imports = [../../modules];

  options.home-user = with types; let
    user = import ../../modules/users/user.nix;
  in {
    username = mkOption {
      default = user.username;
      type = str;
    };
  };
}
