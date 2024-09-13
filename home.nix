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
      antlr
      bat
      bat-extras.batman
      bottom
      chicken
      chuck
      clang
      clang-tools
      cookiecutter
      coreutils
      dejavu_fonts
      delta
      dogdns
      duf
      dust
      elixir
      elixir-ls
      erlang
      erlang-ls
      eza
      fastfetch
      fd
      fh
      font-awesome
      fzf
      gh
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
      iosevka
      jdt-language-server
      jq
      just
      liberation_ttf
      lilypond-unstable-with-fonts
      lldb
      markdown-oxide
      marksman
      nb
      (nerdfonts.override {fonts = ["CascadiaCode"];})
      nil
      nix-search-cli
      nodePackages.bash-language-server
      nodePackages.prettier
      nodePackages.typescript-language-server
      openjdk
      ov
      pandoc
      pipx
      pup
      pyright
      racket-minimal
      rakudo
      rclone
      ripgrep
      ruff-lsp
      rustup
      sd
      shfmt
      swiProlog
      taplo
      tinymist
      tealdeer
      typst
      typst-lsp
      typstyle
      ubuntu_font_family
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
      extraConfig = "map kitty_mod+enter launch --cwd=current --type=window";

      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        enabled_layouts = "grid, stack, vertical, horizontal, tall";
        font_family = "CaskaydiaCove Nerd Font Mono";
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
