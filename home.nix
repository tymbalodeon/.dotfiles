{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home = {
    file = {
      ".gitconfig".source = ./.gitconfig;
      ".config/bat/config".source = ./bat/config;
      ".config/helix/config.toml".source = ./helix/config.toml;
      ".config/helix/languages.toml".source = ./helix/languages.toml;
      ".config/helix/themes/theme.toml".source = ./helix/themes/theme.toml;
      ".config/kitty/theme.conf".source = ./kitty/theme.conf;
      ".config/tinty/fzf.toml".source = ./tinty/fzf.toml;
      ".config/tinty/helix.toml".source = ./tinty/helix.toml;
      ".config/tinty/kitty.toml".source = ./tinty/kitty.toml;
      ".config/tinty/shell.toml".source = ./tinty/shell.toml;
    };

    packages = with pkgs; [
      alejandra
      bat
      dejavu_fonts
      delta
      eza
      fastfetch
      fd
      fh
      font-awesome
      fzf
      gh
      git
      gitui
      jq
      just
      lilypond-unstable
      helix
      marksman
      (nerdfonts.override {fonts = ["CascadiaCode"];})
      nil
      nixfmt
      nodePackages.pyright
      pipx
      rclone
      ripgrep
      ruff-lsp
      rustup
      sd
      taplo
      tldr
      ubuntu_font_family
      vivid
      vscode-langservers-extracted
      yazi
      zoxide
    ];

    sessionVariables = {EDITOR = "hx";};
    stateVersion = "23.11";
    username = "benrosen";
  };

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
      extraConfig = "map kitty_mod+enter launch --cwd=current --type=window";

      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        font_family = "CaskaydiaCove Nerd Font";
        include = "theme.conf";
      };
    };

    nushell = {
      enable = true;
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
    };
  };
}
