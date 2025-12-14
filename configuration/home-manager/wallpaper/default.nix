{pkgs, ...}: let
  wallpaper = ./wallpaper.jpeg;
in {
  home = {
    file."wallpaper/wallpaper.jpeg".source = wallpaper;
    packages = [pkgs.swaybg];
  };

  services = {
    wpaperd = {
      enable = true;

      settings.default = {
        duration = "15m";
        exec = ./signal-waybar.sh;
        mode = "fit";
        path = "~/wallpaper";
      };
    };
  };
}
