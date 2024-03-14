{ pkgs, ... }:

{
  imports = [ ../home.nix ];

  home = {
    file = {
      ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
      ".config/hypr/hyprpaper.conf".source = ./hypr/hyprpaper.conf;
      ".config/hypr/wallpaper".source = ./hypr/wallpaper;
      ".config/nushell/aliases.nu".source = ../nushell/aliases.nu;
      ".config/nushell/colors.nu".source = ../nushell/colors.nu;
      ".config/nushell/functions.nu".source = ../nushell/functions.nu;
      ".config/nushell/prompt.nu".source = ../nushell/prompt.nu;
      ".config/nushell/theme.nu".source = ../nushell/theme.nu;
      ".config/nushell/themes.toml".source = ../nushell/themes.toml;
      ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
      ".config/waybar/style.css".source = ./waybar/style.css;
      ".rustup/settings.toml".source = ./rustup/settings.toml;
    };

    homeDirectory = "/home/benrosen";
    packages = with pkgs; [ mako rofi-wayland zathura ];
  };

  programs.kitty.settings.font_size = "8.0";
}
