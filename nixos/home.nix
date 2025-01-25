{pkgs, ...}: {
  home = {
    file = {
      ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
      ".config/hypr/hyprpaper.conf".source = ./hypr/hyprpaper.conf;
      ".config/hypr/wallpaper".source = ./hypr/wallpaper;
      ".config/mako/config".source = ./mako/config;
      ".config/nushell/aliases.nu".source = ../nushell/aliases.nu;
      ".config/nushell/cloud.nu".source = ../nushell/cloud.nu;
      ".config/nushell/colors.nu".source = ../nushell/colors.nu;
      ".config/nushell/f.nu".source = ../nushell/f.nu;
      ".config/nushell/prompt.nu".source = ../nushell/prompt.nu;
      ".config/nushell/src.nu".source = ../nushell/src.nu;
      ".config/nushell/theme-function.nu".source = ./nushell/theme-function.nu;
      ".config/nushell/theme.nu".source = ../nushell/theme.nu;
      ".config/nushell/themes.toml".source = ../nushell/themes.toml;
      ".config/rofi/config.rasi".source = ./rofi/config.rasi;
      ".config/tealdeer/config.toml".source = ../tealdeer/config.toml;
      ".config/tinty/fzf.toml".source = ./tinty/fzf.toml;
      ".config/tinty/mako.toml".source = ./tinty/mako.toml;
      ".config/tinty/rofi.toml".source = ./tinty/rofi.toml;
      ".gitconfig".source = ../.gitconfig;
      ".rustup/settings.toml".source = ./rustup/settings.toml;
    };

    homeDirectory = "/home/benrosen";

    packages = with pkgs; [
      brightnessctl
      discord
      gforth
      ghostty
      mako
      rofi-wayland
      wev
      wl-clipboard
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
  };

  imports = [../home.nix];

  programs = {
    ghostty = {
      enable = true;
      installBatSyntax = true;

      settings = {
        font-family = "Fira Code";

        font-feature = [
          "+zero"
          "+onum"
          "+cv30"
          "+ss09"
          "+cv25"
          "+cv26"
          "+cv32"
          "+ss07"
        ];

        font-size = 8;

        keybind = [
          "ctrl+shift+l=new_split:right"
          "ctrl+shift+j=new_split:down"
          "ctrl+alt+k=goto_split:top"
          "ctrl+alt+j=goto_split:bottom"
          "ctrl+alt+h=goto_split:left"
          "ctrl+alt+l=goto_split:right"
          "ctrl+alt+p=scroll_page_up"
          "ctrl+alt+n=scroll_page_down"
        ];

        window-decoration = false;
      };
    };

    kitty.settings = {
      font_size = "8.0";
      kitty_mod = "ctrl+shift";
    };
  };
}
