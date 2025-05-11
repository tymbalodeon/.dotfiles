{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      bottom # has hm option
      coreutils
      dogdns
      dust
      eza # has hm option
      fastfetch # has hm option
      fd # hs hm option
      fzf # has hm option
      glow
      gnupg # has hm option
      hexyl
      hyperfine
      jq # has hm option
      just
      nix-search-cli
      ov
      pipx
      pup
      python313
      rainfrog
      rclone # has hm option
      repgrep
      ripgrep # has hm option
      sd
      xh
      yazi # has hm option
      yq-go
      zathura # has hm option
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
