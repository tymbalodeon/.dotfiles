{pkgs, ...}: {
  home.packages = with pkgs; [
    swaybg
    xwayland-satellite
  ];

  programs = {
    fuzzel.enable = true;
    swaylock.enable = true;
  };

  services = {
    mako.enable = true;
    swayidle.enable = true;
    # TODO: is this why solaar suddenly appeared in the tray?? If so, move it elsewhere!
    polkit-gnome.enable = true;
  };

  xdg.configFile."niri/config.kdl" = {
    force = true;
    source = ./config.kdl;
  };
}
