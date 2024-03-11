{ pkgs, ... }:

{
  imports = [ ./home.nix ];

  home = {
    file = {
      ".config/hypr/hyprland.conf".source = ../hypr/hyprland.conf;
      ".config/hypr/hyprpaper.conf".source = ../hypr/hyprpaper.conf;
      ".config/hypr/wallpaper".source = ../hypr/wallpaper;
      ".config/waybar/config.jsonc".source = ../waybar/config.jsonc;
      ".config/waybar/style.css".source = ../waybar/style.css;
    };

    homeDirectory = "/home/benrosen";
    packages = with pkgs; [ mako rofi-wayland zathura ];
  };
}
