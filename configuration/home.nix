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
      nix-search-cli
      ov
      pipx
      pup
      python313
      rainfrog
      repgrep
      sd
      uutils-coreutils-noprefix
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
