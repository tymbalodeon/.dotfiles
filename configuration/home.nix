{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      dogdns
      dua
      dust
      fd
      glow
      hexyl
      hyperfine
      just
      # TODO: add module with rmpc
      mpd
      mprocs
      nix-search-cli
      ov
      pipx
      # TODO: make its own module?
      presenterm
      pup
      python313
      rainfrog
      repgrep
      # TODO: add module with mpd
      rmpc
      sd
      uutils-coreutils-noprefix
      wiki-tui
      xh
      yq-go
    ];

    stateVersion = "23.11";
  };

  imports = [./modules];
  news.display = "silent";
  nixpkgs.config.allowUnfree = true;

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;
  };
}
