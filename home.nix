{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home = {
    file = {
      ".gitconfig".source = ./.gitconfig;
      ".hushlogin".source = ./.hushlogin;
      ".config/helix/config.toml".source = ./helix/config.toml;
      ".config/helix/languages.toml".source = ./helix/languages.toml;
      ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
      ".config/hypr/hyprpaper.conf".source = ./hypr/hyprpaper.conf;
      ".config/hypr/wallpaper".source = ./hypr/wallpaper;
      ".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
      ".config/kitty/current-theme.conf".source = ./kitty/current-theme.conf;
      ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
      ".config/waybar/style.css".source = ./waybar/style.css;
      ".doom.d/config.el".source = ./emacs/config.el;
      ".doom.d/init.el".source = ./emacs/init.el;
      ".doom.d/packages.el".source = ./emacs/packages.el;
    };

    # homeDirectory = "/home/benrosen";
    homeDirectory = "/Users/benrosen";

    packages = with pkgs; [
      bat
      dejavu_fonts
      delta
      emacs
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

    nushell = {
      enable = true;
      configFile.source = ./nushell/config.nu;
      envFile.source = ./nushell/env.nu;
    };
  };
}
