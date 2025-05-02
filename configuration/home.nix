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
      # rustup
      sd
      # shfmt
      socat # TODO nb
      tealdeer
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

  imports = [
    # TODO: loop over the modules directory instead
    ./modules/bat
    ./modules/fonts
    ./modules/git
    ./modules/helix
    ./modules/jujutsu
    ./modules/kitty
    ./modules/nushell
    ./modules/tinty
    ./modules/vivid
    ./modules/zellij
  ];

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
