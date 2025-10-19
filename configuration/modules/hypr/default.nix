{
  config,
  hostName,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.hypr;
    configDirectory = config.nushell.configDirectory;
  in {
    # TODO: use programs.hyprland.enable, etc. (for stylix)
    home = {
      file = {
        "${configDirectory}/hyprland-set-gaps.nu".source = ./hyprland-set-gaps.nu;
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

  imports = [../nushell];

  options.hypr = with types; {
    laptop = mkOption {
      default = false;
      type = bool;
    };
  };
}
