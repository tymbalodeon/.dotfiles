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
      ".config/nushell/theme.nu".source = ../nushell/theme.nu;
      ".config/nushell/theme-function.nu".source = ./nushell/theme-function.nu;
      ".config/nushell/themes.toml".source = ../nushell/themes.toml;
      ".config/rofi/config.rasi".source = ./rofi/config.rasi;
      ".config/waybar/colors.css".source = ./waybar/colors.css;
      ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
      ".config/waybar/style.css".source = ./waybar/style.css;
      ".config/tinty/fzf.toml".source = ./tinty/fzf.toml;
      ".config/tinty/rofi.toml".source = ./tinty/rofi.toml;
      ".config/tinty/mako.toml".source = ./tinty/mako.toml;
      ".config/tinty/waybar.toml".source = ./tinty/waybar.toml;
      ".gitconfig".source = ../.gitconfig;
      ".rustup/settings.toml".source = ./rustup/settings.toml;
    };

    homeDirectory = "/home/benrosen";

    packages = with pkgs; [
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-land
      elmPackages.elm-language-server
      elmPackages.elm-pages
      elmPackages.lamdera
      gforth
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
  programs.kitty.settings.font_size = "8.0";
}
