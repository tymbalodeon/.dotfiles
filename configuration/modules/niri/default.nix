{pkgs, ...}: {
  home.packages = with pkgs; [
    swaybg
    xwayland-satellite
  ];

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
