{
  inputs,
  pkgs,
  ...
}: {
  home = {
    file = {
      ".config/bat/config".source = ./bat/config;

      ".config/bat/syntaxes/nushell.sublime-syntax".source =
        inputs.nushell-syntax + "/nushell.sublime-syntax";

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
      # TODO: move commented packages to `environments` configurations
      bat
      bat-extras.batman
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
      tinty
      # tinymist
      # typst
      # typstyle
      # unison-ucm
      vivid
      w3m # TODO nb
      xh
      yazi
      yq-go
      zathura
      zellij
      # zola
      zoxide
    ];

    sessionVariables = {EDITOR = "hx";};
    stateVersion = "23.11";
    # TODO: separate anything personal from anything else, to make non-personal
    # configurations shareable to other people
    username = "benrosen";
  };

  imports = [./fonts.nix];
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
        font_size = 11;
        inactive_text_alpha = 0.5;
        include = "theme.conf";
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      };
    };

    nushell = {
      configFile.source = ./nushell/config.nu;
      enable = true;
      envFile.source = ./nushell/env.nu;

      plugins = with pkgs.nushellPlugins; [
        formats
        gstat
        polars
        query
      ];
    };
  };
}
