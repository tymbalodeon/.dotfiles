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

    file."${config.nushell.configDirectory}/set-brightness.nu".source =
      ./set-brightness.nu;

    packages = with pkgs; [
      xwayland-satellite
    ];
  };

  imports = [
    ../fuzzel
    ../hyprlock
    ../polkit
  ];

  programs.swaylock.enable = true;

  xdg.configFile."niri/config.kdl" = {
    force = true;
    source = ./config.kdl;
  };
}
