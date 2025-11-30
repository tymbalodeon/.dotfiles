{pkgs, ...}: {
  home.packages = with pkgs; [
    swaybg
    xwayland-satellite
  ];

  programs = {
    alacritty.enable = true;
    fuzzel.enable = true;
    swaylock.enable = true;
    waybar.enable = true;
  };

  services = {
    mako.enable = true;
    swayidle.enable = true;
    polkit-gnome.enable = true;
  };

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
