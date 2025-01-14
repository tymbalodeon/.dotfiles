{
  nushell-syntax,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = true;

  home = {
    file = {
      ".config/bat/config".source = ./bat/config;

      ".config/bat/syntaxes/nushell.sublime-syntax".source =
        nushell-syntax + "/nushell.sublime-syntax";

      ".config/helix/config.toml".source = ./helix/config.toml;
      ".config/helix/languages.toml".source = ./helix/languages.toml;
      ".config/helix/themes/theme.toml".source = ./helix/themes/theme.toml;
      ".config/kitty/theme.conf".source = ./kitty/theme.conf;
      ".config/tinty/helix.toml".source = ./tinty/helix.toml;
      ".config/tinty/kitty.toml".source = ./tinty/kitty.toml;
      ".config/tinty/shell.toml".source = ./tinty/shell.toml;
      ".config/vivid/themes/theme.yml".source = ./vivid/themes/theme.yml;
      ".config/zellij/themes/theme.kdl".source = ./zellij/themes/theme.kdl;
    };

    packages = with pkgs; [
      alejandra
      ansible-language-server
      # TODO evaluate
      atac
      bat
      bat-extras.batman
      bottom
      chuck
      clang
      clang-tools
      coreutils
      dejavu_fonts
      delta
      dogdns
      duf
      dust
      eza
      fastfetch
      fd
      fh
      fira-code
      font-awesome
      fzf
      gh
      ghc
      ghostty
      git
      gitui
      glab
      glow
      gnum4
      google-java-format
      gyre-fonts
      helix
      hexyl
      hyperfine
      ibm-plex
      inconsolata
      jdt-language-server
      jq
      just
      liberation_ttf
      lilypond-unstable-with-fonts
      lldb
      markdown-oxide
      marksman
      nb
      nil
      nix-search-cli
      nodePackages.bash-language-server
      nodePackages.prettier
      nodePackages.typescript-language-server
      noto-fonts
      openjdk
      ov
      pandoc
      pipx
      pup
      pyright
      python313
      rainfrog
      rakudo
      rclone
      repgrep
      ripgrep
      ruff-lsp
      rustup
      sd
      serie
      shfmt
      taplo
      tealdeer
      tinty
      tinymist
      # TODO evaluate
      tui-journal
      typst
      typst-lsp
      typstyle
      ubuntu_font_family
      unison-ucm
      vivid
      vscode-langservers-extracted
      w3m
      xh
      yaml-language-server
      yamlfmt
      yazi
      yq-go
      zathura
      zellij
      zola
      zoxide
    ];

    sessionVariables = {EDITOR = "hx";};
    stateVersion = "23.11";
    username = "benrosen";
  };

  news.display = "silent";
  nixpkgs.config.allowUnfree = true;

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

    helix = {
      enable = true;
      defaultEditor = true;
    };

    home-manager.enable = true;

    kitty = {
      enable = true;
      extraConfig = ''
        map kitty_mod+enter launch --cwd=current --type=window
        font_features FiraCodeRoman-Regular +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
        font_features FiraCodeRoman-SemiBold +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
      '';

      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        enabled_layouts = "grid, stack, vertical, horizontal, tall";
        font_family = "Fira Code";
        inactive_text_alpha = "0.5";
        include = "theme.conf";
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      };
    };

    nushell = {
      enable = true;
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
    };
  };
}
