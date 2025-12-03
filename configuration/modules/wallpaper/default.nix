{pkgs, ...}: {
  home = {
    file."wallpaper/wallpaper.jpeg".source = ./wallpaper.jpeg;
    packages = with pkgs; [
      imagemagick
      swaybg
    ];
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
        mode = "fit";
        path = "~/wallpaper";
      };
    };
  };
}
