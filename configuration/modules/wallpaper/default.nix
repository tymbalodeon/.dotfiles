{pkgs, ...}: {
  home = {
    file."wallpaper/wallpaper.jpeg".source = ./wallpaper.jpeg;

    packages = with pkgs; [
      imagemagick
      swaybg
    ];
  };

  imports = [../nushell];

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
        exec = ./signal-waybar.nu;
        mode = "fit";
        path = "~/wallpaper";
      };
    };
  };
}
