{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      bottom
      coreutils
      dogdns
      dust
      eza
      fastfetch
      fd
      fzf
      glow
      gnupg
      hexyl
      hyperfine
      jq
      just
      nix-search-cli
      ov
      pipx
      pup
      python313
      rainfrog
      rclone
      repgrep
      ripgrep
      sd
      xh
      yazi
      yq-go
      zathura
      zoxide
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
