{
  config,
  hostName,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hypr;
in {
  config = {
    home = {
      file = {
        ".config/hypr/hypridle.conf".source = ./hypridle.conf;
        ".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
        ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;

        ".config/hypr/hyprland.conf".source =
          if hostName == "bumbirich"
          then ./hyprland-bumbirich.conf
          else ./hyprland.conf;

        ".config/hypr/wallpaper".source = ./wallpaper;
      };

      packages = with pkgs;
        [
          hyprlock
          hyprpicker
        ]
        ++ (
          if cfg.laptop
          then [brightnessctl]
          else []
        );
    };
  };

  options.hypr = with types; {
    laptop = mkOption {
      default = false;
      type = bool;
    };
  };
}
