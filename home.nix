{ pkgs, ... }:

rec {
  fonts.fontconfig.enable = true;

  home = {
    file = {
      ".gitconfig".source = ./.gitconfig;
      ".hushlogin".source = ./.hushlogin;
      ".config/helix/config.toml".source = ./helix/config.toml;
      ".config/helix/languages.toml".source = ./helix/languages.toml;
      # ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
      # ".config/hypr/hyprpaper.conf".source = ./hypr/hyprpaper.conf;
      # ".config/hypr/wallpaper".source = ./hypr/wallpaper;
      # ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
      # ".config/waybar/style.css".source = ./waybar/style.css;
    };

    # homeDirectory = "/home/benrosen";
    homeDirectory = "/Users/benrosen";

    packages = with pkgs; [
      bat
      dejavu_fonts
      delta
      eza
      fd
      fh
      fira
      font-awesome
      fzf
      git
      gitui
      jq
      lilypond-unstable
      helix
      macchina
      # mako
      marksman
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      nil
      nixfmt
      pipx
      ripgrep
      rustup
      # rofi-wayland
      sd
      tldr
      vivid
      vscode-langservers-extracted
      yazi
      zoxide
    ];

    stateVersion = "23.11";
    username = "benrosen";

    sessionVariables = {
      EDITOR = "hx";
    };
  };

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

      settings = {
        confirm_os_window_close = 0;
        font_family = "CaskaydiaCove Nerd Font";
        hide_window_decorations = "yes";
        macos_quit_when_last_window_closed = "yes";
        shell = "${home.homeDirectory}/.nix-profile/bin/nu";
      };

      theme = "Gruvbox Dark";
    };

    nushell = {
      enable = true;
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
    };
  };
}
