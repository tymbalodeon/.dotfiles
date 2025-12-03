{
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    activation.niri =
      lib.hm.dag.entryAfter ["writeBoundary"]
      ''mkdir --parents ~/Pictures/Screenshots'';

    file."${config.nushell.configDirectory}/brightness.nu".source =
      ../monitors/brightness.nu;

    packages = with pkgs; [
      xwayland-satellite
    ];
  };

  imports = [
    ../fuzzel
    ../hyprlock
    ../music-player
    ../nushell
    ../playerctl
    ../polkit
    ../swaybg
    ../swaync
    ../waybar
  ];

  programs.swaylock.enable = true;

  xdg.configFile."niri/config.kdl" = {
    force = true;

    text =
      (builtins.readFile ./config.kdl)
      + ''spawn-at-startup "swaybg" "--image" "${../../wallpaper.jpeg}"'';
  };
}
