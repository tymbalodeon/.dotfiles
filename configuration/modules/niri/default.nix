{pkgs, ...}: {
  home.packages = with pkgs; [
    swaybg
    xwayland-satellite
  ];

  imports = [
    ../fuzzel
    ../polkit
  ];

  programs.swaylock.enable = true;

  xdg.configFile."niri/config.kdl" = {
    force = true;
    source = ./config.kdl;
  };
}
