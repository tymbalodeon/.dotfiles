{
  inputs,
  pkgs,
  ...
}: {
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
  };

  imports = [./modules];
  news.display = "silent";

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;
  };
}
