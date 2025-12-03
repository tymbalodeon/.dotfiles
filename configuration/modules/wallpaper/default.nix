{pkgs, ...}: {
  home = {
    file."wallpaper/wallpaper.jpeg".source = ./wallpaper.jpeg;
    packages = [pkgs.swaybg];
  };

  services = {
    hyprpaper.settings = let
      wallpaper = "${./wallpaper.jpeg}";
    in {
      preload = "${wallpaper}";
      wallpaper = [", ${wallpaper}"];
    };

    wpaperd = {
      enable = true;

      settings.default = {
        duration = "15m";
        path = "~/wallpaper";
      };
    };
  };
}
