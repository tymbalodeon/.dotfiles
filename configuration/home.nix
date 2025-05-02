{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      bottom
      coreutils
      delta
      dogdns
      duf
      dust
      eza
      fastfetch
      fd
      fzf
      gh
      gitui
      # TODO: used by `src`, but remove this when rust version is implemented
      # glab
      glow
      gnupg
      harper
      hexyl
      hyperfine
      jq
      just
      marksman
      nb
      nix-search-cli
      ov
      pandoc # TODO nb (possibly others?)
      pipx
      pup
      python313
      rainfrog
      rclone
      repgrep
      ripgrep
      # ruff
      sd
      # shfmt
      socat # TODO nb
      tig # TODO nb
      w3m # TODO nb
      xh
      yazi
      yq-go
      zathura
      zoxide
    ];

    stateVersion = "23.11";
    # TODO: separate anything personal from anything else, to make non-personal
    # configurations shareable to other people
    username = "benrosen";
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
