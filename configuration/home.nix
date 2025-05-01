{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # TODO: move commented packages to `environments` configurations
      bottom
      # clang
      # clang-tools
      coreutils
      delta
      dogdns
      duf
      dust
      eza
      fastfetch
      fd
      # fh
      fzf
      gh
      # ghc
      gitui
      # TODO: used by `src`, but remove this when rust version is implemented
      # glab
      glow
      gnupg
      # google-java-format
      harper
      hexyl
      hyperfine
      # jdt-language-server
      jq
      just
      # lldb
      marksman
      nb
      nix-search-cli
      # nodePackages.bash-language-server
      # nodePackages.typescript-language-server
      # openjdk
      ov
      pandoc # TODO nb (possibly others?)
      pipx
      pup
      # pyright
      python313
      rainfrog
      # rakudo
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
      # tinymist
      # typst
      # typstyle
      # unison-ucm
      w3m # TODO nb
      xh
      yazi
      yq-go
      zathura
      # zola
      zoxide
    ];

    sessionVariables = {EDITOR = "hx";};
    stateVersion = "23.11";
    # TODO: separate anything personal from anything else, to make non-personal
    # configurations shareable to other people
    username = "benrosen";
  };

  imports = [
    ./bat
    ./fonts.nix
    ./helix
    ./kitty
    ./nushell
    ./tinty
    ./vivid
    ./zellij
  ];

  news.display = "silent";

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName = "Ben Rosen";
      userEmail = "benjamin.j.rosen@gmail.com";
    };

    home-manager.enable = true;
  };
}
