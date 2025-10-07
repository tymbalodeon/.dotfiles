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
      uutils-coreutils-noprefix
      wiki-tui
      xh
      yq-go
    ];

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
